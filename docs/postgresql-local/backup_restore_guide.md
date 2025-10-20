# Backup & Restore Guide - Hospital Management System

Student: FAIAN  
Project: Hospital Management System  
Option: 3 - Coding-Heavy DBA / DevOps Project  
Database: PostgreSQL 13+

---

## Overview
This document explains how to protect and recover the Hospital Management System (HMS) database when it runs on PostgreSQL. The procedures balance Recovery Point Objective (RPO) and Recovery Time Objective (RTO) targets for a healthcare environment where data loss must be minimal and recovery must be predictable.

- Target RTO: under 4 hours for a full restore.
- Target RPO: under 15 minutes when WAL archiving is enabled.
- Data sensitivity: HIPAA-aligned handling with encrypted storage and audited access.

---

## Backup Strategy

| Layer | Frequency | Retention | Purpose |
| --- | --- | --- | --- |
| Full logical backup (`pg_dump`) | Daily at 02:00 | 30 days | Point-in-time snapshot for rapid restores and migration. |
| Incremental WAL archive | Every 5 minutes | 7 days | Protects last transactions between full backups. |
| Physical base backup (`pg_basebackup`) | Weekly | 4 copies | Bare-metal recovery and replica provisioning. |
| Offsite copy | Weekly | 90 days | Disaster recovery in a separate region or cloud bucket. |

Store backups on isolated storage (for example, mounted NAS, S3 bucket, Azure Blob) and monitor job success with alerts.

---

## Tooling

| Tool | Use case | Notes |
| --- | --- | --- |
| `pg_dump` / `pg_restore` | Logical exports and restores | Use custom format (`-F c`) for compression and selective restore. |
| `pg_basebackup` | Physical backup with WAL shipping | Requires archive_mode and replication role. |
| `psql` | Running pre- and post-backup checks | Automate integrity checks and verification queries. |
| `gzip` / `7z` | Compressing backup files | Reduce storage costs; encrypt as needed. |
| `gpg` | Encryption at rest | Protects PHI in backup archives. |

---

## Preparation Checklist
- Create a dedicated PostgreSQL role for backups with the `pg_read_all_data`, `pg_read_all_settings`, and `pg_read_all_stats` privileges.
- Ensure `archive_mode = on` and `archive_command` is configured to ship WAL files to secure storage.
- On Windows, add PostgreSQL's `bin` directory to the system `PATH`; on Linux, run backups as the `postgres` system user.
- Keep a secure location (password manager or vault) for database credentials and encryption keys.

---

## Full Logical Backup with `pg_dump`

### PowerShell (Windows)
```powershell
$env:PGPASSWORD = "StrongPasswordHere"
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backupDir = "D:\pg_backups\hospital_management"
$backupFile = "$backupDir\hospital_full_$timestamp.dump"

New-Item -ItemType Directory -Force -Path $backupDir | Out-Null

pg_dump `
    -h localhost `
    -p 5432 `
    -U hms_admin `
    -d hospital_management `
    -F c `
    -b `
    -f $backupFile

if ($LASTEXITCODE -ne 0) {
    Write-Error "Backup failed with exit code $LASTEXITCODE"
} else {
    Write-Host "Backup completed: $backupFile"
}
```

### Bash (Linux)
```bash
export PGPASSWORD="StrongPasswordHere"
timestamp=$(date +"%Y%m%d_%H%M%S")
backup_dir="/var/backups/postgres/hospital_management"
backup_file="$backup_dir/hospital_full_$timestamp.dump"

mkdir -p "$backup_dir"

pg_dump \
  -h 127.0.0.1 \
  -p 5432 \
  -U hms_admin \
  -d hospital_management \
  -F c \
  -b \
  -f "$backup_file"

if [ $? -ne 0 ]; then
  echo "Backup failed" >&2
  exit 1
fi

gzip "$backup_file"
```

---

## Schema-Only and Data-Only Backups

```bash
# Schema only
pg_dump -h localhost -U hms_admin -d hospital_management --schema-only -f schema_only.sql

# Selected tables (data only)
pg_dump -h localhost -U hms_admin -d hospital_management \
    --data-only \
    --table=appointments \
    --table=billing \
    -f operational_data.sql
```

These exports are useful for version control, migrations, or refreshing development environments.

---

## Restoring from Logical Backups

### Drop and recreate the database (if necessary)
```bash
dropdb -h localhost -U postgres hospital_management
createdb -h localhost -U postgres hospital_management
```

### Restore custom-format dump
```bash
pg_restore \
  -h localhost \
  -p 5432 \
  -U hms_admin \
  -d hospital_management \
  --clean \
  --create \
  /path/to/hospital_full_20251009_020000.dump
```

If the dump contains the `CREATE DATABASE` statement, omit the manual `dropdb`/`createdb` step and rely on `--create`.

### Restore from plain SQL
```bash
psql -h localhost -U hms_admin -d hospital_management -f hospital_full_20251009.sql
```

After restoration, run smoke tests:

```bash
psql -d hospital_management -c "SELECT COUNT(*) FROM patients;"
psql -d hospital_management -c "SELECT * FROM v_patient_summary LIMIT 5;"
```

---

## Physical Backups with `pg_basebackup`

1. Ensure WAL archiving is enabled in `postgresql.conf`:
   ```
   wal_level = replica
   archive_mode = on
   archive_command = 'copy "%p" "D:/pg_wal_archive/%f"'
   ```
2. Create a replication role:
   ```sql
   CREATE ROLE hms_replica WITH REPLICATION LOGIN ENCRYPTED PASSWORD 'AnotherStrongPassword';
   ```
3. Run the base backup:
   ```bash
   pg_basebackup \
     -h localhost \
     -p 5432 \
     -U hms_replica \
     -D /backups/hms/base_2025_10_09 \
     -Fp \
     -Xs \
     -P
   ```
4. Copy archived WAL files to the same location so that point-in-time recovery is possible.

Physical backups are ideal for building read replicas or restoring onto new hardware.

---

## Automating Backups

### PowerShell scheduled task
Save the following as `scripts\backup_hms.ps1` and schedule it with Windows Task Scheduler.

```powershell
param(
    [string]$OutputDir = "D:\pg_backups\hospital_management",
    [int]$RetentionDays = 30
)

$env:PGPASSWORD = "StrongPasswordHere"
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$file = "$OutputDir\hospital_full_$timestamp.dump"

New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

pg_dump -h localhost -U hms_admin -d hospital_management -F c -b -f $file

Get-ChildItem $OutputDir -Filter "hospital_full_*.dump" |
    Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-$RetentionDays) } |
    Remove-Item
```

### Cron job (Linux)
```
0 2 * * * /usr/local/bin/backup_hms.sh >> /var/log/backup_hms.log 2>&1
```

Ensure scripts exit with non-zero status on failure so monitoring can alert the DBA team.

---

## Disaster Recovery Playbooks

### Scenario 1: Accidental Data Deletion
1. Stop application access to prevent further writes.
2. Restore the most recent full dump to a staging database.
3. Reapply WAL segments using `pg_waldump` or `pg_restore` with selective table restore.
4. Verify affected records and then swap staging into production.

### Scenario 2: Hardware Failure
1. Provision new PostgreSQL host (cloud VM or on-prem server).
2. Restore latest physical base backup.
3. Replay archived WAL files until just before failure.
4. Reconfigure application connection strings and run smoke tests.

### Scenario 3: Corrupted Table or Index
1. Use `pg_checksums` and `pg_amcheck` to validate extent of corruption.
2. Restore only the affected table from logical backup into a staging schema.
3. Validate row counts and constraints.
4. Swap clean data back into production using `ALTER TABLE ... SET SCHEMA` or `INSERT ... SELECT`.

Document lessons learned after each incident and update procedures accordingly.

---

## Validation Checklist
- [ ] Backup job completed without errors.
- [ ] Backup file exists and is larger than zero bytes.
- [ ] `pg_restore --list` succeeds (for custom-format dumps).
- [ ] Monthly restore test performed on an isolated environment.
- [ ] WAL archive directory has recent files (if archiving enabled).
- [ ] Integrity checks (`SELECT COUNT(*)`, sample spot checks) match expected baselines.

---

## Security Considerations
- Encrypt backup files with GPG or a managed key service:
  ```bash
  gpg --symmetric --cipher-algo AES256 hospital_full_20251009.dump
  ```
- Restrict file permissions (`chmod 600` on Linux, NTFS ACLs on Windows).
- Rotate credentials used for backups at least quarterly.
- Audit backup access via operating system logs and vault access records.
- Store encryption keys separately from the backup payloads.

---

## Contacts
- Database Administrator: [Your contact]
- IT Security Team: [Your contact]
- Program Sponsor / Instructor: [Your contact]

Keep this guide with your runbook repository and review it after every major change to the HMS database or infrastructure.
