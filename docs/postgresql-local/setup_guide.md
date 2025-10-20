# Hospital Management System - PostgreSQL Setup Guide

## 📋 Overview

Complete installation and configuration guide for deploying the Hospital Management System on local PostgreSQL database server.

**Target Platform:** PostgreSQL 13 or higher  
**Operating Systems:** Windows, Linux, macOS  
**Estimated Setup Time:** 30-45 minutes  
**Skill Level:** Intermediate

---

## 🎯 Prerequisites

### Required Software

1. **PostgreSQL Database** (Version 13+)
   - Download: https://www.postgresql.org/download/
   - Required components: PostgreSQL Server, pgAdmin 4, Command Line Tools

2. **pgAdmin 4** (Database Management Tool)
   - Bundled with PostgreSQL installer
   - Alternative: DBeaver, DataGrip

3. **Text Editor** (Optional)
   - VS Code, Notepad++, or any code editor

### System Requirements

- **RAM:** Minimum 4GB (8GB recommended)
- **Disk Space:** 2GB for PostgreSQL + 500MB for data
- **CPU:** Any modern processor (2+ cores recommended)
- **Network:** Internet connection for initial setup only

---

## 📥 Step 1: PostgreSQL Installation

### Windows Installation

1. **Download PostgreSQL Installer**
   ```
   Visit: https://www.postgresql.org/download/windows/
   Download: postgresql-16.x-windows-x64.exe (or latest version)
   ```

2. **Run Installer**
   - Double-click the downloaded installer
   - Click "Next" through welcome screens
   - Installation Directory: `C:\Program Files\PostgreSQL\16`
   - Select Components:
     - ✅ PostgreSQL Server
     - ✅ pgAdmin 4
     - ✅ Command Line Tools
   - Data Directory: `C:\Program Files\PostgreSQL\16\data`

3. **Set Superuser Password**
   - Username: `postgres` (default)
   - Password: **Choose a strong password** (remember this!)
   - Port: `5432` (default)

4. **Complete Installation**
   - Locale: `Default locale`
   - Click "Next" → "Finish"
   - Uncheck "Stack Builder" (not needed)

### Linux Installation (Ubuntu/Debian)

```bash
# Update package list
sudo apt update

# Install PostgreSQL
sudo apt install postgresql postgresql-contrib -y

# Verify installation
sudo systemctl status postgresql

# Switch to postgres user
sudo -i -u postgres

# Access PostgreSQL shell
psql
```

### macOS Installation

```bash
# Using Homebrew
brew install postgresql@16

# Start PostgreSQL service
brew services start postgresql@16

# Access PostgreSQL shell
psql postgres
```

---

## 🔧 Step 2: Database Setup

### Option A: Using pgAdmin 4 (Graphical Interface)

1. **Launch pgAdmin 4**
   - Windows: Start Menu → pgAdmin 4
   - Set master password when prompted

2. **Connect to PostgreSQL Server**
   - Left panel: Servers → PostgreSQL 16
   - Enter password you set during installation

3. **Create New Database**
   - Right-click "Databases" → "Create" → "Database..."
   - Database Name: `hospital_management`
   - Owner: `postgres`
   - Encoding: `UTF8`
   - Click "Save"

### Option B: Using Command Line (psql)

```bash
# Connect to PostgreSQL
psql -U postgres

# Create database
CREATE DATABASE hospital_management;

# Connect to the new database
\c hospital_management

# Verify connection
SELECT current_database();
```

---

## 📊 Step 3: Schema Creation

### Load Database Schema

1. **Locate Schema File**
   ```
   File: sql/postgresql/schema.sql
   Location: hospital-management/sql/postgresql/
   ```

2. **Execute Using pgAdmin**
   - Select database: `hospital_management`
   - Click "Tools" → "Query Tool" (or press Alt+Shift+Q)
   - Click "Open File" icon → Select `schema.sql`
   - Click "Execute" (F5) to run the script
   - Check "Messages" tab for success confirmation

3. **Execute Using Command Line**
   ```bash
   # Navigate to project directory
   cd path/to/hospital-management

   # Execute schema script
   psql -U postgres -d hospital_management -f sql/postgresql/schema.sql

   # Expected output: CREATE TABLE messages for each table
   ```

### Verify Schema Creation

```sql
-- Check all tables were created
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;

-- Expected tables (10 total):
-- admissions, appointments, audit_log, billing, departments,
-- doctors, medical_tests, patients, prescriptions, staff
```

---

## 📥 Step 4: Data Loading

### Load Sample Data from CSV Files

1. **Prepare Data Directory**
   ```
   Location: hospital-management/datasets/
   Files: 10 CSV files (departments.csv, doctors.csv, etc.)
   ```

2. **Execute Load Script**

   **Using pgAdmin:**
   - Query Tool → Open File → `sql/postgresql/load_data.sql`
   - **IMPORTANT:** Edit file paths in script to match your system
   - Execute script (F5)

   **Using Command Line:**
   ```bash
   # Execute load data script
   psql -U postgres -d hospital_management -f sql/postgresql/load_data.sql
   ```

3. **Alternative: Manual CSV Import (if paths need adjustment)**

   ```sql
   -- Example for importing departments
   \COPY departments(department_id, department_name, floor_number, phone_extension, department_head) 
   FROM 'C:/path/to/datasets/departments.csv' 
   DELIMITER ',' 
   CSV HEADER;
   ```

### Verify Data Import

```sql
-- Check record counts
SELECT 'departments' AS table_name, COUNT(*) AS records FROM departments
UNION ALL
SELECT 'doctors', COUNT(*) FROM doctors
UNION ALL
SELECT 'patients', COUNT(*) FROM patients
UNION ALL
SELECT 'staff', COUNT(*) FROM staff
UNION ALL
SELECT 'appointments', COUNT(*) FROM appointments
UNION ALL
SELECT 'admissions', COUNT(*) FROM admissions
UNION ALL
SELECT 'prescriptions', COUNT(*) FROM prescriptions
UNION ALL
SELECT 'medical_tests', COUNT(*) FROM medical_tests
UNION ALL
SELECT 'billing', COUNT(*) FROM billing
UNION ALL
SELECT 'audit_log', COUNT(*) FROM audit_log;

-- Expected total: 217 records
```

---

## 🔒 Step 5: Security Configuration

### Create Database Roles

```bash
# Execute roles script
psql -U postgres -d hospital_management -f sql/postgresql/roles.sql
```

### Configure User Access

```sql
-- Create example users for each role
CREATE USER admin_user WITH PASSWORD 'SecurePass123!';
CREATE USER doctor_user WITH PASSWORD 'SecurePass123!';
CREATE USER nurse_user WITH PASSWORD 'SecurePass123!';

-- Assign roles
GRANT hospital_admin TO admin_user;
GRANT medical_doctor TO doctor_user;
GRANT nursing_staff TO nurse_user;

-- Test role permissions
\c hospital_management admin_user
SELECT * FROM patients LIMIT 5; -- Should work for admin
```

---

## 🎨 Step 6: Views and Triggers

### Install Views

```bash
# Load database views
psql -U postgres -d hospital_management -f sql/postgresql/views.sql
```

### Verify Views

```sql
-- List all views
SELECT table_name 
FROM information_schema.views 
WHERE table_schema = 'public';

-- Test a view
SELECT * FROM patient_appointment_history LIMIT 10;
```

### Install Triggers

```bash
# Load triggers and functions
psql -U postgres -d hospital_management -f sql/postgresql/triggers.sql
```

### Test Triggers

```sql
-- Test audit trigger
UPDATE patients 
SET phone = '617-555-9999' 
WHERE patient_id = 1;

-- Check audit log
SELECT * FROM audit_log 
WHERE table_name = 'patients' 
ORDER BY changed_at DESC 
LIMIT 5;
```

---

## ✅ Step 7: Verification & Testing

### System Verification Checklist

```sql
-- 1. Check database exists
SELECT current_database();

-- 2. Verify all tables
SELECT COUNT(*) AS table_count 
FROM information_schema.tables 
WHERE table_schema = 'public' AND table_type = 'BASE TABLE';
-- Expected: 10 tables

-- 3. Check total records
SELECT 
    (SELECT COUNT(*) FROM departments) +
    (SELECT COUNT(*) FROM doctors) +
    (SELECT COUNT(*) FROM patients) +
    (SELECT COUNT(*) FROM staff) +
    (SELECT COUNT(*) FROM appointments) +
    (SELECT COUNT(*) FROM admissions) +
    (SELECT COUNT(*) FROM prescriptions) +
    (SELECT COUNT(*) FROM medical_tests) +
    (SELECT COUNT(*) FROM billing) +
    (SELECT COUNT(*) FROM audit_log) AS total_records;
-- Expected: 217 records

-- 4. Verify views
SELECT COUNT(*) AS view_count 
FROM information_schema.views 
WHERE table_schema = 'public';
-- Expected: 5+ views

-- 5. Check triggers
SELECT DISTINCT trigger_name 
FROM information_schema.triggers 
WHERE event_object_schema = 'public';
-- Expected: 2+ triggers

-- 6. Test constraints
SELECT COUNT(*) AS constraint_count 
FROM information_schema.table_constraints 
WHERE table_schema = 'public';
-- Expected: 80+ constraints
```

### Sample Queries Test

```sql
-- Test Query 1: Doctor workload
SELECT 
    d.first_name || ' ' || d.last_name AS doctor_name,
    d.specialization,
    COUNT(a.appointment_id) AS total_appointments
FROM doctors d
LEFT JOIN appointments a ON d.doctor_id = a.doctor_id
GROUP BY d.doctor_id, d.first_name, d.last_name, d.specialization
ORDER BY total_appointments DESC
LIMIT 10;

-- Test Query 2: Patient billing summary
SELECT 
    p.first_name || ' ' || p.last_name AS patient_name,
    p.insurance_provider,
    COUNT(b.billing_id) AS total_bills,
    SUM(b.total_amount) AS total_charges,
    SUM(b.patient_responsibility) AS patient_owes
FROM patients p
JOIN billing b ON p.patient_id = b.patient_id
GROUP BY p.patient_id, p.first_name, p.last_name, p.insurance_provider
ORDER BY total_charges DESC;
```

---

## 🛠️ Troubleshooting

### Common Issues and Solutions

#### Issue 1: Connection Refused
```
Error: could not connect to server: Connection refused
```

**Solution:**
```bash
# Check if PostgreSQL is running
sudo systemctl status postgresql  # Linux
net start postgresql-x64-16       # Windows (as Administrator)

# Restart PostgreSQL
sudo systemctl restart postgresql  # Linux
net stop postgresql-x64-16 && net start postgresql-x64-16  # Windows
```

#### Issue 2: CSV Import Path Errors
```
Error: could not open file "path/to/file.csv" for reading
```

**Solution:**
```sql
-- Use absolute paths with forward slashes
-- Windows example:
\COPY departments FROM 'C:/Users/YourName/Desktop/hospital-management/datasets/departments.csv' CSV HEADER;

-- Linux/Mac example:
\COPY departments FROM '/home/username/hospital-management/datasets/departments.csv' CSV HEADER;
```

#### Issue 3: Permission Denied
```
Error: permission denied for table patients
```

**Solution:**
```sql
-- Grant necessary permissions
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO your_username;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO your_username;
```

#### Issue 4: Encoding Errors
```
Error: invalid byte sequence for encoding "UTF8"
```

**Solution:**
```sql
-- Recreate database with correct encoding
DROP DATABASE hospital_management;
CREATE DATABASE hospital_management 
    WITH ENCODING = 'UTF8' 
    LC_COLLATE = 'en_US.UTF-8' 
    LC_CTYPE = 'en_US.UTF-8';
```

---

## 🔄 Backup and Restore

See the separate **Backup & Restore Guide** (`backup_restore_guide.md`) for detailed instructions on:
- Creating automated backups
- Restoring from backup files
- Point-in-time recovery
- Disaster recovery procedures

---

## 📚 Next Steps

After successful setup:

1. **Run Sample Queries** (`sql/postgresql/queries.sql`)
2. **Review Documentation** (`README.md`)
3. **Configure Backups** (`backup_restore_guide.md`)
4. **Explore Views** (Test business intelligence queries)
5. **Test Security** (Verify role-based access)

---

## 💡 Tips and Best Practices

1. **Regular Backups:** Schedule daily automated backups
2. **Monitor Performance:** Use `EXPLAIN ANALYZE` for slow queries
3. **Index Optimization:** Review query plans regularly
4. **Connection Pooling:** Use pgBouncer for production
5. **Security:** Change default passwords immediately
6. **Maintenance:** Run `VACUUM ANALYZE` weekly

---

## 📞 Support Resources

- **PostgreSQL Documentation:** https://www.postgresql.org/docs/
- **pgAdmin Documentation:** https://www.pgadmin.org/docs/
- **SQL Tutorial:** https://www.postgresql.org/docs/current/tutorial.html
- **Project Issues:** Contact system administrator

---

## 📄 License

This Hospital Management System is provided for educational and demonstration purposes.

---

**Setup Complete!** 🎉 Your Hospital Management System is now ready for use.
