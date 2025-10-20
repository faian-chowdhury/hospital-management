# SQL Scripts - Hospital Management System

## 📂 Directory Structure

This directory contains SQL scripts organized for dual deployment options:

```
sql/
├── postgresql/       # Local PostgreSQL deployment scripts
│   ├── schema.sql           # Database structure
│   ├── load_data.sql        # CSV data import (\COPY commands)
│   ├── views.sql            # Business intelligence views
│   ├── triggers.sql         # Automated triggers & functions
│   ├── roles.sql            # User roles & permissions
│   └── queries.sql          # Sample queries & reports
│
└── supabase/         # Cloud Supabase deployment scripts
    ├── schema.sql           # Database structure
    ├── insert_data.sql      # Direct data insertion (INSERT statements)
    ├── views.sql            # Business intelligence views
    ├── triggers.sql         # Automated triggers & functions
    ├── roles_rls.sql        # Row Level Security policies
    └── queries.sql          # Sample queries & reports
```

---

## 🎯 Deployment Options

### Option 1: Local PostgreSQL
**Use Case:** On-premise deployment, full control, offline access

**Setup:**
1. Install PostgreSQL 13+ locally
2. Follow: `../docs/postgresql/setup_guide.md`
3. Execute scripts in order:
   ```bash
   psql -U postgres -d hospital_management -f postgresql/schema.sql
   psql -U postgres -d hospital_management -f postgresql/load_data.sql
   psql -U postgres -d hospital_management -f postgresql/views.sql
   psql -U postgres -d hospital_management -f postgresql/triggers.sql
   psql -U postgres -d hospital_management -f postgresql/roles.sql
   ```

**Pros:** ✅ Full control, ✅ No internet required, ✅ Custom configuration  
**Cons:** ❌ Manual setup, ❌ No auto-generated APIs, ❌ Self-managed backups

---

### Option 2: Cloud Supabase
**Use Case:** Web apps, mobile apps, real-time features, quick deployment

**Setup:**
1. Create free Supabase account
2. Follow: `../docs/supabase/supabase_setup_guide.md`
3. Execute scripts in Supabase SQL Editor:
   - `supabase/schema.sql`
   - `supabase/insert_data.sql`
   - `supabase/views.sql`
   - `supabase/triggers.sql`
   - `supabase/roles_rls.sql`

**Pros:** ✅ Instant setup, ✅ Auto APIs, ✅ Built-in auth, ✅ Auto backups  
**Cons:** ❌ Internet required, ❌ 500MB free tier limit, ❌ Less customization

---

## 📊 Database Schema Overview

### Core Tables (10 Total)

| Table | Records | Description |
|-------|---------|-------------|
| `departments` | 12 | Hospital departments with contact info |
| `doctors` | 20 | Medical staff credentials & specializations |
| `patients` | 25 | Patient demographics & insurance |
| `staff` | 15 | Non-physician hospital personnel |
| `appointments` | 30 | Doctor-patient consultations |
| `admissions` | 15 | Inpatient hospital stays |
| `prescriptions` | 25 | Medication orders with dosage |
| `medical_tests` | 30 | Diagnostic tests & lab results |
| `billing` | 30 | Financial transactions & insurance claims |
| `audit_log` | 15 | System activity audit trail |

**Total Records:** 217

---

## 🔐 Security Features

### PostgreSQL (Traditional Roles)
- **Roles:** 5 hierarchical roles
- **Permissions:** GRANT-based access control
- **Auditing:** Trigger-based audit logging
- **Implementation:** `postgresql/roles.sql`

### Supabase (Row Level Security)
- **RLS Policies:** 35+ fine-grained policies
- **User Context:** JWT-based authentication
- **HIPAA Compliance:** Patient data isolation
- **Implementation:** `supabase/roles_rls.sql`

---

## 📈 Business Intelligence Views

Both deployments include these analytical views:

1. **patient_appointment_history** - Complete patient visit records
2. **doctor_schedule_summary** - Physician workload analysis
3. **patient_billing_summary** - Financial overview per patient
4. **department_revenue** - Revenue by department
5. **active_admissions_overview** - Current inpatient census

**Query Examples:** See `queries.sql` in respective folders

---

## 🔄 Automated Triggers

### Audit Logging Trigger
- **Trigger:** `audit_trigger`
- **Tables:** All data tables
- **Function:** `audit_changes()`
- **Logs:** INSERT, UPDATE, DELETE operations
- **Storage:** `audit_log` table with JSONB

### Appointment Status Trigger
- **Trigger:** `update_appointment_status`
- **Table:** `appointments`
- **Logic:** Auto-complete past appointments
- **Frequency:** On INSERT/UPDATE

---

## 🚀 Quick Start

### For PostgreSQL Developers
```bash
# 1. Create database
createdb hospital_management

# 2. Run all scripts
cd sql/postgresql
for file in schema.sql load_data.sql views.sql triggers.sql roles.sql; do
    psql -d hospital_management -f $file
done

# 3. Test queries
psql -d hospital_management -f queries.sql
```

### For Supabase Users
```
1. Open Supabase Dashboard
2. Go to SQL Editor
3. Copy-paste each script from sql/supabase/
4. Execute in order: schema → insert_data → views → triggers → roles_rls
5. Test with queries.sql examples
```

---

## 📝 File Descriptions

### schema.sql
- **Purpose:** Create all database tables
- **Content:** CREATE TABLE statements with constraints
- **Indexes:** 50+ performance indexes
- **Constraints:** 80+ data integrity rules
- **Size:** ~400 lines

### load_data.sql (PostgreSQL) / insert_data.sql (Supabase)
- **Purpose:** Populate tables with sample data
- **PostgreSQL:** Uses `\COPY` from CSV files
- **Supabase:** Uses `INSERT` statements
- **Records:** 217 total records
- **Size:** ~200 lines (PostgreSQL), ~750 lines (Supabase)

### views.sql
- **Purpose:** Create analytical views
- **Views:** 5+ business intelligence queries
- **Joins:** Multi-table complex joins
- **Aggregations:** COUNT, SUM, AVG calculations
- **Size:** ~150 lines

### triggers.sql
- **Purpose:** Automate database operations
- **Functions:** PL/pgSQL stored procedures
- **Triggers:** BEFORE/AFTER event handlers
- **Features:** Audit logging, status updates
- **Size:** ~100 lines

### roles.sql (PostgreSQL) / roles_rls.sql (Supabase)
- **Purpose:** Security and access control
- **PostgreSQL:** Role-based permissions
- **Supabase:** Row Level Security policies
- **Roles:** 5 user types (admin to patient)
- **Size:** ~200 lines (PostgreSQL), ~600 lines (Supabase)

### queries.sql
- **Purpose:** Sample SQL queries and reports
- **Queries:** 10+ practical examples
- **Complexity:** Simple to advanced
- **Features:** JOINs, subqueries, aggregations, CTEs
- **Size:** ~300 lines

---

## 🧪 Testing Your Setup

### Basic Verification
```sql
-- Check all tables exist
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
ORDER BY table_name;

-- Verify record counts
SELECT 
    (SELECT COUNT(*) FROM departments) AS dept,
    (SELECT COUNT(*) FROM doctors) AS docs,
    (SELECT COUNT(*) FROM patients) AS patients,
    (SELECT COUNT(*) FROM appointments) AS appts,
    (SELECT COUNT(*) FROM billing) AS bills;
```

### Test Queries
```sql
-- Top 5 busiest doctors
SELECT 
    d.first_name || ' ' || d.last_name AS doctor,
    COUNT(a.appointment_id) AS appointments
FROM doctors d
LEFT JOIN appointments a ON d.doctor_id = a.doctor_id
GROUP BY d.doctor_id, d.first_name, d.last_name
ORDER BY appointments DESC
LIMIT 5;

-- Revenue by insurance provider
SELECT 
    p.insurance_provider,
    COUNT(*) AS claims,
    SUM(b.total_amount) AS total_billed,
    SUM(b.insurance_covered) AS insurance_paid
FROM billing b
JOIN patients p ON b.patient_id = p.patient_id
GROUP BY p.insurance_provider
ORDER BY total_billed DESC;
```

---

## 📚 Additional Resources

- **Setup Guides:** `../docs/postgresql/` and `../docs/supabase/`
- **Backup Guide:** `../docs/postgresql/backup_restore_guide.md`
- **Main README:** `../README.md`
- **Dataset Info:** `../datasets/README.md`

---

## 🤝 Contributing

When modifying SQL scripts:

1. **Keep Parity:** Update both PostgreSQL and Supabase versions
2. **Test Thoroughly:** Verify on clean database
3. **Document Changes:** Update comments and this README
4. **Check Constraints:** Ensure foreign keys and data types match
5. **Version Control:** Commit with clear messages

---

## 📞 Support

For questions or issues with SQL scripts:
- Review setup guides in `docs/` folder
- Check PostgreSQL documentation: https://www.postgresql.org/docs/
- Check Supabase docs: https://supabase.com/docs
- Contact: Database Administrator

---

**Last Updated:** January 2025  
**Database Version:** PostgreSQL 13+  
**Total Scripts:** 12 files (6 per deployment option)
