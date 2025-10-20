# 🏥 Hospital Management System Database

> **A Detailed healthcare database system built for modern medical facilities**

[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-13%2B-blue?logo=postgresql)](https://www.postgresql.org/)
[![Supabase](https://img.shields.io/badge/Supabase-Compatible-green?logo=supabase)](https://supabase.com/)
[![License](https://img.shields.io/badge/License-Educational-orange)](LICENSE)
[![Status](https://img.shields.io/badge/Status-Production%20Ready-success)](README.md)

**Project Information:**
- **Student:** FAIAN
- **Course:** Database Management Systems - Mid-Term Project
- **Option:** 3 (Coding-Heavy DBA/DevOps Track)
- **Database:** PostgreSQL 13+ | Supabase Cloud
- **Date:** January 2025

---

## 📋 Table of Contents

- [Overview](#-overview)
- [System Architecture](#-system-architecture)
- [Features](#-features)
- [Database Schema](#-database-schema)
- [Quick Start](#-quick-start)
- [Deployment Options](#-deployment-options)
- [Security & Compliance](#-security--compliance)
- [Sample Queries](#-sample-queries)
- [Documentation](#-documentation)
- [Project Statistics](#-project-statistics)

---

## 🎯 Overview

The **Hospital Management System** is an enterprise-grade relational database designed to manage the complex workflows of modern healthcare facilities. This system handles everything from patient registration and appointment scheduling to medical records, billing, and compliance auditing.

### Why This System?

🏥 **Medical-Grade Data Integrity**
- 80+ constraints ensuring clinical accuracy
- HIPAA-compliant audit logging
- Referential integrity across all patient records

💼 **Real-World Operations**
- 217 realistic healthcare records
- Multi-specialty department management
- Insurance claim processing
- Electronic medical records (EMR) foundation

🚀 **Dual Deployment Options**
- **Local PostgreSQL:** On-premise, full control
- **Supabase Cloud:** Instant setup with auto-generated APIs

### Use Cases

- ✅ Teaching hospital database administration
- ✅ Healthcare application backend
- ✅ Medical records system prototype
- ✅ Database performance optimization lab
- ✅ SQL query practice with realistic data

---

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    CLIENT LAYER                         │
│  (Doctors, Nurses, Patients, Billing Staff, Admins)    │
└────────────────────┬────────────────────────────────────┘
                     │
┌────────────────────┴────────────────────────────────────┐
│              APPLICATION LAYER (Optional)               │
│  REST APIs • GraphQL • Real-time Subscriptions          │
└────────────────────┬────────────────────────────────────┘
                     │
┌────────────────────┴────────────────────────────────────┐
│              SECURITY & ACCESS CONTROL                   │
│  Row Level Security • Role-Based Access • JWT Auth      │
└────────────────────┬────────────────────────────────────┘
                     │
┌────────────────────┴────────────────────────────────────┐
│              DATABASE LOGIC LAYER                        │
│  Triggers • Functions • Views • Constraints             │
└────────────────────┬────────────────────────────────────┘
                     │
┌────────────────────┴────────────────────────────────────┐
│              DATA STORAGE LAYER                          │
│  10 Tables • 217 Records • 50+ Indexes • Audit Trail    │
└─────────────────────────────────────────────────────────┘
```

---

## ✨ Features

### Core Functionality

| Feature | Description | Implementation |
|---------|-------------|----------------|
| 🏢 **Department Management** | 12 hospital departments with organizational hierarchy | `departments` table |
| 👨‍⚕️ **Doctor Registry** | 20 physicians with specializations & credentials | `doctors` table |
| 🧑‍⚕️ **Patient Records** | 25 comprehensive patient profiles with insurance | `patients` table |
| 👥 **Staff Management** | 15 non-physician staff with shift schedules | `staff` table |
| 📅 **Appointment System** | 30 scheduled consultations with status tracking | `appointments` table |
| 🛏️ **Admission Management** | 15 inpatient episodes with room assignments | `admissions` table |
| 💊 **Prescription Tracking** | 25 medication orders with dosage & refills | `prescriptions` table |
| 🔬 **Medical Tests** | 30 diagnostic tests with results | `medical_tests` table |
| 💰 **Billing & Insurance** | 30 financial transactions with claim processing | `billing` table |
| 📝 **Audit Logging** | Comprehensive change tracking for compliance | `audit_log` table |

### Advanced Database Features

✅ **Business Intelligence Views** (5+ analytical views)
- Patient visit history with outcomes
- Doctor workload and scheduling analysis
- Revenue reporting by department and insurance
- Active admissions census dashboard
- Prescription fulfillment tracking

✅ **Automated Triggers** (7+ event-driven functions)
- Audit trail for all data modifications
- Automatic timestamp updates
- Appointment status synchronization
- Billing amount calculations
- Data validation and business rules

✅ **Security Policies** (35+ RLS policies for Supabase)
- Role-based data access (5 user roles)
- Patient data privacy (HIPAA-style isolation)
- Doctor-patient relationship enforcement
- Billing department restrictions
- Admin override capabilities

✅ **Query Optimization** (50+ strategic indexes)
- Foreign key relationship indexes
- Date range query optimization
- Full-text search preparation
- Composite indexes for common joins
- Covering indexes for frequent queries

---

## 📊 Database Schema

### Entity Relationship Overview

The database follows **Third Normal Form (3NF)** with the following entity relationships:

```
DEPARTMENTS (1) ──┬──> (N) DOCTORS
                  │
                  └──> (N) STAFF

PATIENTS (1) ──┬──> (N) APPOINTMENTS
               │
               ├──> (N) ADMISSIONS
               │
               ├──> (N) PRESCRIPTIONS
               │
               ├──> (N) MEDICAL_TESTS
               │
               └──> (N) BILLING

DOCTORS (1) ──┬──> (N) APPOINTMENTS
              │
              ├──> (N) ADMISSIONS (as attending)
              │
              ├──> (N) PRESCRIPTIONS
              │
              └──> (N) MEDICAL_TESTS

AUDIT_LOG ◄────── All Tables (via triggers)
```

### Tables Summary

| Table | Records | Key Fields | Relationships |
|-------|---------|------------|---------------|
| `departments` | 12 | department_id (PK) | → doctors, staff |
| `doctors` | 20 | doctor_id (PK), department_id (FK) | ← departments, → appointments |
| `patients` | 25 | patient_id (PK) | → appointments, admissions, billing |
| `staff` | 15 | staff_id (PK), department_id (FK) | ← departments |
| `appointments` | 30 | appointment_id (PK), patient_id (FK), doctor_id (FK) | ← patients, doctors |
| `admissions` | 15 | admission_id (PK), patient_id (FK), attending_doctor_id (FK) | ← patients, doctors |
| `prescriptions` | 25 | prescription_id (PK), patient_id (FK), doctor_id (FK) | ← patients, doctors |
| `medical_tests` | 30 | test_id (PK), patient_id (FK), doctor_id (FK) | ← patients, doctors |
| `billing` | 30 | billing_id (PK), patient_id (FK), appointment_id (FK) | ← patients, appointments |
| `audit_log` | 15 | log_id (PK), table_name, operation | Logs all table changes |

**Total Records:** 217  
**Total Constraints:** 80+ (PKs, FKs, CHECKs, UNIQUEs)  
**Total Indexes:** 50+ (Performance optimization)

---

## 🚀 Quick Start

### Option 1: Local PostgreSQL (Traditional)

**Prerequisites:**
- PostgreSQL 13 or higher
- psql command-line tool
- 2GB available disk space

**Installation Steps:**

```bash
# 1. Create database
createdb hospital_management

# 2. Navigate to project directory
cd hospital-management

# 3. Execute schema
psql -U postgres -d hospital_management -f sql/postgresql/schema.sql

# 4. Load sample data
psql -U postgres -d hospital_management -f sql/postgresql/load_data.sql

# 5. Create views
psql -U postgres -d hospital_management -f sql/postgresql/views.sql

# 6. Install triggers
psql -U postgres -d hospital_management -f sql/postgresql/triggers.sql

# 7. Setup roles & security
psql -U postgres -d hospital_management -f sql/postgresql/roles.sql

# 8. Test with sample queries
psql -U postgres -d hospital_management -f sql/postgresql/queries.sql
```

**📖 Detailed Guide:** See `docs/postgresql/setup_guide.md`

---

### Option 2: Supabase Cloud (Modern)

**Prerequisites:**
- Free Supabase account
- Web browser
- 15 minutes

**Deployment Steps:**

1. **Create Account:** Visit https://supabase.com and sign up
2. **New Project:** Dashboard → "New Project"
   - Name: `hospital-management-system`
   - Password: [Generate strong password]
   - Region: [Select nearest]
3. **Open SQL Editor:** Dashboard → SQL Editor
4. **Execute Scripts** (in order):
   - Copy & paste `sql/supabase/schema.sql` → RUN
   - Copy & paste `sql/supabase/insert_data.sql` → RUN
   - Copy & paste `sql/supabase/views.sql` → RUN
   - Copy & paste `sql/supabase/triggers.sql` → RUN
   - Copy & paste `sql/supabase/roles_rls.sql` → RUN
5. **Test:** Run queries from `sql/supabase/queries.sql`

**📖 Detailed Guide:** See `docs/supabase/supabase_setup_guide.md`

---

## 🌐 Deployment Options

### Comparison Matrix

| Feature | Local PostgreSQL | Supabase Cloud |
|---------|------------------|----------------|
| **Setup Time** | 30-45 minutes | 15-20 minutes |
| **Cost** | Free (self-hosted) | Free tier: 500MB |
| **Internet Required** | No | Yes |
| **Auto APIs** | No (manual) | Yes (REST + GraphQL) |
| **Authentication** | Manual | Built-in JWT |
| **Backups** | Manual | Automatic daily |
| **Scaling** | Manual | Automatic |
| **Real-time** | Via extensions | Built-in |
| **Best For** | Learning, on-premise | Production apps, mobile |

### When to Use Each

**Use PostgreSQL if:**
- 🎓 Learning database administration
- 🏢 On-premise requirements
- 💻 Offline access needed
- ⚙️ Full system control required

**Use Supabase if:**
- 🚀 Building web/mobile apps
- ⚡ Need instant APIs
- 🔄 Want real-time features
- ☁️ Prefer managed hosting

---

## 🔒 Security & Compliance

### HIPAA-Ready Features

This system implements healthcare data protection standards:

✅ **Access Control**
- 5 role-based user types
- Principle of least privilege
- Separation of duties

✅ **Audit Trail**
- All data changes logged
- Immutable audit history
- User attribution
- Timestamp tracking

✅ **Data Privacy**
- Row Level Security (RLS)
- Patient data isolation
- Doctor-patient confidentiality
- Emergency contact protection

✅ **Encryption**
- SSL/TLS connections (Supabase default)
- Password hashing
- Secure credential storage

### User Roles

| Role | Access Level | Can View | Can Modify |
|------|-------------|----------|------------|
| `hospital_admin` | Full System | All tables | All tables |
| `medical_doctor` | Clinical Data | Patients, appointments, prescriptions, tests | Own appointments, prescriptions |
| `nursing_staff` | Patient Care | Patients, appointments, admissions | Appointments, admissions |
| `billing_clerk` | Financial | Patients (demographics), billing | Billing only |
| `patient_user` | Personal Data | Own records only | Own appointments (create) |

---

## 📝 Sample Queries

### Query Examples from `sql/queries.sql`

#### 1. Doctor Workload Analysis
```sql
-- Find doctors with the most appointments
SELECT 
    d.first_name || ' ' || d.last_name AS doctor_name,
    d.specialization,
    dep.department_name,
    COUNT(a.appointment_id) AS total_appointments,
    COUNT(CASE WHEN a.status = 'Completed' THEN 1 END) AS completed,
    COUNT(CASE WHEN a.status = 'Scheduled' THEN 1 END) AS upcoming
FROM doctors d
LEFT JOIN appointments a ON d.doctor_id = a.doctor_id
LEFT JOIN departments dep ON d.department_id = dep.department_id
GROUP BY d.doctor_id, d.first_name, d.last_name, d.specialization, dep.department_name
ORDER BY total_appointments DESC
LIMIT 10;
```

#### 2. Patient Billing Summary
```sql
-- Calculate patient financial overview
SELECT 
    p.first_name || ' ' || p.last_name AS patient_name,
    p.insurance_provider,
    COUNT(b.billing_id) AS total_bills,
    SUM(b.total_amount) AS total_charged,
    SUM(b.insurance_covered) AS insurance_paid,
    SUM(b.patient_responsibility) AS patient_owes,
    ROUND(AVG(b.patient_responsibility), 2) AS avg_copay
FROM patients p
LEFT JOIN billing b ON p.patient_id = b.patient_id
GROUP BY p.patient_id, p.first_name, p.last_name, p.insurance_provider
HAVING COUNT(b.billing_id) > 0
ORDER BY total_charged DESC;
```

#### 3. Department Revenue Analysis
```sql
-- Revenue by hospital department
SELECT 
    dep.department_name,
    COUNT(DISTINCT d.doctor_id) AS num_doctors,
    COUNT(a.appointment_id) AS total_appointments,
    SUM(b.total_amount) AS total_revenue,
    ROUND(AVG(b.total_amount), 2) AS avg_bill_amount
FROM departments dep
LEFT JOIN doctors d ON dep.department_id = d.department_id
LEFT JOIN appointments a ON d.doctor_id = a.doctor_id
LEFT JOIN billing b ON a.appointment_id = b.appointment_id
GROUP BY dep.department_id, dep.department_name
ORDER BY total_revenue DESC NULLS LAST;
```

#### 4. Active Admissions Dashboard
```sql
-- Current inpatient census
SELECT 
    p.first_name || ' ' || p.last_name AS patient_name,
    a.room_number || '-' || a.bed_number AS bed_assignment,
    a.admission_type,
    a.primary_diagnosis,
    d.first_name || ' ' || d.last_name AS attending_doctor,
    a.admission_date,
    CURRENT_DATE - a.admission_date AS days_admitted
FROM admissions a
JOIN patients p ON a.patient_id = p.patient_id
JOIN doctors d ON a.attending_doctor_id = d.doctor_id
WHERE a.discharge_date IS NULL
ORDER BY a.admission_date;
```

**More Examples:** See `sql/postgresql/queries.sql` or `sql/supabase/queries.sql` for 10+ additional queries including:
- Prescription tracking and refill management
- Medical test result summaries
- Insurance claim analytics
- Appointment scheduling optimization
- Staff shift management

---

## 📚 Documentation

### Setup & Deployment

| Document | Description | Path |
|----------|-------------|------|
| **PostgreSQL Setup Guide** | Complete local installation instructions | `docs/postgresql/setup_guide.md` |
| **Supabase Setup Guide** | Cloud deployment walkthrough | `docs/supabase/supabase_setup_guide.md` |
| **Backup & Restore Guide** | Disaster recovery procedures | `docs/postgresql/backup_restore_guide.md` |
| **SQL Scripts README** | Script organization and execution order | `sql/README.md` |
| **Dataset Information** | CSV file descriptions and data sources | `datasets/README.md` |

### Key Files

```
hospital-management/
├── README.md                    ← You are here
├── reflection.tex               ← Project report (LaTeX)
│
├── sql/
│   ├── README.md               ← SQL scripts overview
│   ├── postgresql/             ← Local deployment scripts
│   │   ├── schema.sql          ← Database structure
│   │   ├── load_data.sql       ← CSV import (\COPY)
│   │   ├── views.sql           ← Analytical views
│   │   ├── triggers.sql        ← Automated functions
│   │   ├── roles.sql           ← User permissions
│   │   └── queries.sql         ← Sample queries
│   │
│   └── supabase/               ← Cloud deployment scripts
│       ├── schema.sql          ← Database structure
│       ├── insert_data.sql     ← Direct inserts
│       ├── views.sql           ← Analytical views
│       ├── triggers.sql        ← Automated functions
│       ├── roles_rls.sql       ← RLS policies
│       └── queries.sql         ← Sample queries
│
├── datasets/                   ← CSV data files (10 files)
│   ├── README.md              ← Dataset documentation
│   ├── departments.csv        ← 12 departments
│   ├── doctors.csv            ← 20 physicians
│   ├── patients.csv           ← 25 patients
│   ├── staff.csv              ← 15 staff members
│   ├── appointments.csv       ← 30 appointments
│   ├── admissions.csv         ← 15 admissions
│   ├── prescriptions.csv      ← 25 prescriptions
│   ├── medical_tests.csv      ← 30 tests
│   ├── billing.csv            ← 30 bills
│   └── audit_log.csv          ← 15 audit entries
│
└── docs/                      ← Documentation guides
    ├── postgresql/
    │   ├── setup_guide.md     ← Local setup
    │   └── backup_restore_guide.md
    │
    └── supabase/
        └── supabase_setup_guide.md ← Cloud setup
```

---

## 📊 Project Statistics

### Database Metrics

| Metric | Count | Details |
|--------|-------|---------|
| **Tables** | 10 | Fully normalized (3NF) |
| **Total Records** | 217 | Realistic healthcare data |
| **Relationships** | 15+ | Foreign key constraints |
| **Indexes** | 50+ | Performance-optimized |
| **Constraints** | 80+ | Data integrity rules |
| **Views** | 5+ | Business intelligence |
| **Triggers** | 7+ | Automated workflows |
| **Functions** | 5+ | Reusable logic |
| **RLS Policies** | 35+ | Security (Supabase) |
| **User Roles** | 5 | Access control |

### Code Complexity

| Component | Lines of Code | Description |
|-----------|---------------|-------------|
| **schema.sql** | ~400 | Table definitions, constraints, indexes |
| **load_data.sql** (PostgreSQL) | ~200 | CSV import commands |
| **insert_data.sql** (Supabase) | ~750 | Direct INSERT statements |
| **views.sql** | ~150 | Analytical queries |
| **triggers.sql** | ~100 | Event-driven automation |
| **roles.sql** (PostgreSQL) | ~200 | Permission management |
| **roles_rls.sql** (Supabase) | ~600 | Row Level Security |
| **queries.sql** | ~300 | Sample reports |
| **Total** | ~2,700+ | Lines of production SQL |

### Data Distribution

```
Department Distribution:
Emergency Medicine: 10%
Cardiology: 10%
Surgery: 10%
Other Specialties: 70%

Patient Demographics:
Age Range: 25-50 years
Gender: Balanced
Insurance: 4 major providers
Location: Boston area

Appointment Status:
Completed: 60%
Scheduled: 40%
Cancelled: <1%

Billing Status:
Paid: 80%
Pending: 20%
Average Bill: $8,500
```

---

## 🎓 Learning Outcomes

This project demonstrates proficiency in:

✅ **Database Design**
- Entity-Relationship modeling
- Normalization (3NF)
- Referential integrity
- Business rule implementation

✅ **SQL Programming**
- Complex JOINs (INNER, LEFT, CROSS)
- Subqueries and CTEs
- Window functions
- Aggregate functions

✅ **Database Administration**
- User role management
- Permission granting
- Backup strategies
- Performance tuning

✅ **Security & Compliance**
- Row Level Security (RLS)
- Audit logging
- Data privacy (HIPAA concepts)
- Access control

✅ **DevOps**
- Deployment automation
- Environment management
- Documentation standards
- Version control

---

## 🔧 Troubleshooting

### Common Issues

#### Problem: CSV Import Fails
```
Error: could not open file for reading
```

**Solution:**
- Use absolute file paths
- Check file permissions
- Verify CSV format (UTF-8 encoding)
- Replace backslashes with forward slashes (Windows)

#### Problem: Foreign Key Violations
```
Error: violates foreign key constraint
```

**Solution:**
- Load tables in correct order (see `load_data.sql`)
- Verify parent records exist first
- Check for data type mismatches

#### Problem: RLS Blocking Queries
```
Error: new row violates row-level security policy
```

**Solution:**
- Temporarily disable RLS for testing
- Use service_role key (Supabase)
- Check policy conditions
- Verify user role assignment

#### Problem: Slow Query Performance
```
Query takes >5 seconds
```

**Solution:**
```sql
-- Check if indexes exist
SELECT * FROM pg_indexes WHERE schemaname = 'public';

-- Analyze query plan
EXPLAIN ANALYZE SELECT ...;

-- Create missing indexes
CREATE INDEX idx_name ON table_name(column_name);
```

**More Help:** See setup guides in `docs/` folder

---

## 🚧 Future Enhancements

Potential extensions for this system:

- [ ] **Patient Portal:** Web interface for appointment booking
- [ ] **Real-Time Dashboard:** Live hospital statistics
- [ ] **Mobile App:** iOS/Android patient access
- [ ] **Telemedicine:** Virtual appointment support
- [ ] **Pharmacy Integration:** Prescription fulfillment system
- [ ] **Lab System:** Automated test result imports
- [ ] **Insurance APIs:** Real-time claim verification
- [ ] **Reporting Module:** Automated analytics reports
- [ ] **Multi-Language:** Internationalization support
- [ ] **AI Integration:** Predictive analytics for patient care

---

## 👥 User Roles Reference

### Access Matrix

| Resource | Admin | Doctor | Nurse | Billing | Patient |
|----------|-------|--------|-------|---------|---------|
| Departments | ✅ Full | ✅ Read | ✅ Read | ✅ Read | ❌ None |
| Doctors | ✅ Full | ✅ Read | ✅ Read | ✅ Read | ❌ None |
| Patients | ✅ Full | ✅ Full | ✅ Update | ✅ Read | ✅ Own Only |
| Appointments | ✅ Full | ✅ Own | ✅ Update | ✅ Read | ✅ Own Only |
| Admissions | ✅ Full | ✅ Own | ✅ Update | ✅ Read | ❌ None |
| Prescriptions | ✅ Full | ✅ Create | ✅ Read | ✅ Read | ✅ Own Only |
| Medical Tests | ✅ Full | ✅ Create | ✅ Read | ✅ Read | ✅ Own Only |
| Billing | ✅ Full | ✅ Read | ✅ Read | ✅ Full | ✅ Own Only |
| Audit Log | ✅ Full | ❌ Insert | ❌ Insert | ❌ Insert | ❌ None |

---

## 📜 License & Usage

This Hospital Management System database is provided for **educational purposes only**.

**Permitted Use:**
- ✅ Academic coursework and learning
- ✅ Database administration practice
- ✅ SQL query training
- ✅ Portfolio demonstrations
- ✅ Teaching and workshops

**Restrictions:**
- ❌ Production medical use without proper licensing
- ❌ HIPAA-covered deployments without audit
- ❌ Commercial use without modification
- ❌ Redistribution as original work

**Disclaimer:** This system is a demonstration project. It implements HIPAA-*style* security but is not certified for actual Protected Health Information (PHI). Consult healthcare IT compliance experts before production deployment.

---

## 🤝 Contributing

Contributions welcome! To improve this project:

1. **Report Issues:** Found a bug? Open an issue
2. **Suggest Features:** Ideas for enhancements
3. **Submit Fixes:** Pull requests for corrections
4. **Improve Docs:** Clarify setup instructions

**Guidelines:**
- Maintain SQL formatting consistency
- Update both PostgreSQL and Supabase versions
- Test changes on clean database
- Document new features

---

## 📞 Support & Contact

**For Technical Support:**
- 📖 Review documentation in `docs/` folder
- 🔍 Check troubleshooting section above
- 💬 PostgreSQL community: https://www.postgresql.org/support/
- 💬 Supabase community: https://discord.supabase.com

**For Project Questions:**
- 📧 Contact: Database Administrator
- 🎓 Course: Database Management Systems
- 🏫 Institution: [Your University Name]

---

## 🙏 Acknowledgments

**Technologies Used:**
- PostgreSQL 13+ - World's most advanced open source database
- Supabase - The open source Firebase alternative
- pgAdmin 4 - PostgreSQL management tool

**Data Sources:**
- Synthetic medical data generated for educational use
- Inspired by real-world hospital management systems
- Names and identifiers are fictitious

**Special Thanks:**
- Database Management Systems course instructors
- PostgreSQL documentation contributors
- Supabase team for excellent cloud platform
- Healthcare IT professionals for domain insights

---

## 📈 Project Timeline

```
Week 1: Requirements & Design
  ├── ERD creation
  ├── Table structure planning
  └── Relationship mapping

Week 2: Schema Implementation
  ├── SQL schema coding
  ├── Constraint definition
  └── Index optimization

Week 3: Data Generation
  ├── CSV dataset creation
  ├── Data validation
  └── Import testing

Week 4: Advanced Features
  ├── Views creation
  ├── Trigger implementation
  ├── Security setup
  └── Query optimization

Week 5: Documentation & Testing
  ├── Setup guides
  ├── README creation
  ├── Deployment testing
  └── Final review
```

---

## ✅ Project Checklist

### Database Requirements (Option 3)

- [x] **Minimum 7 tables** (Delivered: 10 tables)
- [x] **200+ records** (Delivered: 217 records)
- [x] **10+ complex queries** (Delivered: 20+ queries)
- [x] **2+ triggers** (Delivered: 7+ triggers)
- [x] **5+ views** (Delivered: 5+ views)
- [x] **User roles & permissions** (Delivered: 5 roles + 35 RLS policies)
- [x] **Backup documentation** (Comprehensive guide)
- [x] **Deployment options** (PostgreSQL + Supabase)
- [x] **Project reflection** (reflection.tex)
- [x] **README documentation** (This file)

### Additional Features (Bonus)

- [x] Row Level Security (Supabase)
- [x] Auto-generated APIs (Supabase)
- [x] Comprehensive audit logging
- [x] Multiple deployment guides
- [x] Performance optimization (50+ indexes)
- [x] Real-world healthcare scenarios
- [x] HIPAA-style compliance features

---

## 🎉 Conclusion

The **Hospital Management System** represents a production-ready database solution for healthcare facilities. With 10 fully normalized tables, 217 realistic records, comprehensive security policies, and dual deployment options, this system demonstrates enterprise-level database design and administration skills.

Whether you're learning database management, building a healthcare application, or practicing SQL optimization, this project provides a solid foundation with real-world complexity and professional documentation.

**Ready to deploy?** Choose your platform:
- 🏢 **Local PostgreSQL:** See `docs/postgresql/setup_guide.md`
- ☁️ **Supabase Cloud:** See `docs/supabase/supabase_setup_guide.md`

---

**Built with ❤️ for Database Management Systems**  
**Student:** FAIAN | **Date:** January 2025 | **Version:** 1.0

```bash
psql -d hospital_management -f sql/schema.sql
psql -d hospital_management -f sql/views.sql
psql -d hospital_management -f sql/triggers.sql
psql -d hospital_management -f sql/roles.sql
```

### 3. Import the sample dataset
```bash
psql -d hospital_management -f sql/load_data.sql
```
The load script uses `\COPY`, so execute it from the repository root where the `datasets/` directory is accessible.

### 4. Run verification queries
```bash
psql -d hospital_management -c "SELECT COUNT(*) FROM patients;"
psql -d hospital_management -c "SELECT * FROM v_upcoming_appointments LIMIT 5;"
psql -d hospital_management -c "SELECT * FROM audit_log ORDER BY changed_at DESC LIMIT 5;"
```

### 5. Explore analytics
Execute `psql -d hospital_management -f sql/queries.sql` to review the analytical examples or copy individual queries into your preferred IDE.

## Maintenance and Operations
The companion `backup_restore_guide.md` documents full and incremental backup routines, WAL archiving, restore drills, and automation strategies for Windows and Linux environments. Combine those steps with PostgreSQL's native monitoring (`pg_stat_statements`, auto-vacuum) to keep the system production-ready.

## Documentation Map
- `backup_restore_guide.md` - backup, recovery, and disaster-recovery scenarios.
- `sql/queries.sql` - library of production-ready analytics and KPI reports.
- `datasets/README.md` - provenance for every CSV dataset.
- `reflection.tex` - narrative reflection on design choices and future enhancements.

## Contact
For questions about the database design, operational considerations, or extension ideas, reach out to FAIAN via the course communication channels or update the issues tracker for this project.

## License
This repository was prepared for academic purposes. You are welcome to adapt the schema and documentation for learning or internal projects; please retain attribution when sharing derivatives.
