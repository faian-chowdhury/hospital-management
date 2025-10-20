-- ================================================
-- Hospital Management System - Data Loading Script
-- Student: FAIAN
-- Option 3: Coding-Heavy DBA / DevOps Project
-- Date: October 9, 2025
-- ================================================

-- This script loads all CSV data into the database
-- Execute after schema.sql has been run

-- ================================================
-- SECTION 1: LOAD DATA IN DEPENDENCY ORDER
-- ================================================

-- Step 1: Load departments (no dependencies)
\COPY departments(department_id, department_name, floor_number, phone_extension, department_head) FROM 'datasets/departments.csv' WITH (FORMAT CSV, HEADER true);

-- Step 2: Load doctors (depends on departments)
\COPY doctors(doctor_id, first_name, last_name, specialization, department_id, license_number, phone, email, years_of_experience, consultation_fee) FROM 'datasets/doctors.csv' WITH (FORMAT CSV, HEADER true);

-- Step 3: Load patients (no dependencies)
\COPY patients(patient_id, first_name, last_name, date_of_birth, gender, blood_type, phone, email, address, city, state, zip_code, emergency_contact_name, emergency_contact_phone, insurance_provider, insurance_policy_number) FROM 'datasets/patients.csv' WITH (FORMAT CSV, HEADER true);

-- Step 4: Load staff (depends on departments)
\COPY staff(staff_id, first_name, last_name, role, department_id, phone, email, hire_date, salary, shift) FROM 'datasets/staff.csv' WITH (FORMAT CSV, HEADER true);

-- Step 5: Load appointments (depends on patients and doctors)
\COPY appointments(appointment_id, patient_id, doctor_id, appointment_date, appointment_time, status, reason, notes) FROM 'datasets/appointments.csv' WITH (FORMAT CSV, HEADER true);

-- Step 6: Load admissions (depends on patients and doctors)
\COPY admissions(admission_id, patient_id, admission_date, discharge_date, room_number, bed_number, admission_type, discharge_status, primary_diagnosis, attending_doctor_id) FROM 'datasets/admissions.csv' WITH (FORMAT CSV, HEADER true);

-- Step 7: Load prescriptions (depends on patients and doctors)
\COPY prescriptions(prescription_id, patient_id, doctor_id, medication_name, dosage, frequency, duration_days, start_date, end_date, refills_allowed, instructions) FROM 'datasets/prescriptions.csv' WITH (FORMAT CSV, HEADER true);

-- Step 8: Load medical tests (depends on patients and doctors)
\COPY medical_tests(test_id, patient_id, doctor_id, test_type, test_name, test_date, status, results, notes) FROM 'datasets/medical_tests.csv' WITH (FORMAT CSV, HEADER true);

-- Step 9: Load billing (depends on patients, appointments, admissions)
\COPY billing(billing_id, patient_id, appointment_id, admission_id, bill_date, total_amount, insurance_covered, patient_responsibility, payment_status, payment_date, payment_method) FROM 'datasets/billing.csv' WITH (FORMAT CSV, HEADER true);

-- Step 10: Load audit log
\COPY audit_log(log_id, table_name, operation, record_id, changed_by, changed_at, old_data, new_data) FROM 'datasets/audit_log.csv' WITH (FORMAT CSV, HEADER true);

-- ================================================
-- SECTION 2: UPDATE SEQUENCES
-- ================================================

-- Reset sequences to max values to avoid conflicts
SELECT setval('departments_department_id_seq', (SELECT MAX(department_id) FROM departments));
SELECT setval('doctors_doctor_id_seq', (SELECT MAX(doctor_id) FROM doctors));
SELECT setval('patients_patient_id_seq', (SELECT MAX(patient_id) FROM patients));
SELECT setval('staff_staff_id_seq', (SELECT MAX(staff_id) FROM staff));
SELECT setval('appointments_appointment_id_seq', (SELECT MAX(appointment_id) FROM appointments));
SELECT setval('admissions_admission_id_seq', (SELECT MAX(admission_id) FROM admissions));
SELECT setval('prescriptions_prescription_id_seq', (SELECT MAX(prescription_id) FROM prescriptions));
SELECT setval('medical_tests_test_id_seq', (SELECT MAX(test_id) FROM medical_tests));
SELECT setval('billing_billing_id_seq', (SELECT MAX(billing_id) FROM billing));
SELECT setval('audit_log_log_id_seq', (SELECT MAX(log_id) FROM audit_log));

-- ================================================
-- SECTION 3: VERIFICATION QUERIES
-- ================================================

-- Verify record counts
SELECT 'departments' AS table_name, COUNT(*) AS record_count FROM departments
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

-- Expected counts:
-- departments: 12
-- doctors: 20
-- patients: 25
-- staff: 15
-- appointments: 30
-- admissions: 15
-- prescriptions: 25
-- medical_tests: 30
-- billing: 30
-- audit_log: 15
-- TOTAL: 217 records

-- Verify foreign key relationships
SELECT 
    'All doctors have valid departments' AS check_name,
    COUNT(*) = 0 AS passed
FROM doctors d
LEFT JOIN departments dept ON d.department_id = dept.department_id
WHERE dept.department_id IS NULL

UNION ALL

SELECT 
    'All appointments have valid patients and doctors',
    COUNT(*) = 0
FROM appointments a
LEFT JOIN patients p ON a.patient_id = p.patient_id
LEFT JOIN doctors d ON a.doctor_id = d.doctor_id
WHERE p.patient_id IS NULL OR d.doctor_id IS NULL

UNION ALL

SELECT 
    'All billing records have valid patients',
    COUNT(*) = 0
FROM billing b
LEFT JOIN patients p ON b.patient_id = p.patient_id
WHERE p.patient_id IS NULL

UNION ALL

SELECT 
    'All prescriptions have valid patients and doctors',
    COUNT(*) = 0
FROM prescriptions pr
LEFT JOIN patients p ON pr.patient_id = p.patient_id
LEFT JOIN doctors d ON pr.doctor_id = d.doctor_id
WHERE p.patient_id IS NULL OR d.doctor_id IS NULL;

-- Verify data integrity
SELECT 
    'Billing amounts sum correctly' AS check_name,
    COUNT(*) AS violations
FROM billing
WHERE ABS(total_amount - (insurance_covered + patient_responsibility)) > 0.01;

SELECT 
    'All discharge dates after admission dates' AS check_name,
    COUNT(*) AS violations
FROM admissions
WHERE discharge_date < admission_date;

SELECT 
    'All prescription end dates after start dates' AS check_name,
    COUNT(*) AS violations
FROM prescriptions
WHERE end_date < start_date;

-- Sample data verification
SELECT 
    'Sample: Departments' AS verification,
    department_name,
    floor_number
FROM departments
LIMIT 3;

SELECT 
    'Sample: Doctors' AS verification,
    first_name || ' ' || last_name AS doctor_name,
    specialization
FROM doctors
LIMIT 3;

SELECT 
    'Sample: Patients' AS verification,
    first_name || ' ' || last_name AS patient_name,
    blood_type
FROM patients
LIMIT 3;

-- ================================================
-- SECTION 4: REFRESH MATERIALIZED VIEWS
-- ================================================

REFRESH MATERIALIZED VIEW mv_doctor_performance;
REFRESH MATERIALIZED VIEW mv_department_analytics;

SELECT 'Materialized views refreshed successfully' AS status;

-- ================================================
-- SECTION 5: SUCCESS MESSAGE
-- ================================================

DO $$
DECLARE
    total_records INTEGER;
BEGIN
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
        (SELECT COUNT(*) FROM audit_log)
    INTO total_records;
    
    RAISE NOTICE '';
    RAISE NOTICE '================================================';
    RAISE NOTICE 'DATA LOADING COMPLETED SUCCESSFULLY!';
    RAISE NOTICE '================================================';
    RAISE NOTICE 'Total records loaded: %', total_records;
    RAISE NOTICE 'Expected records: 217';
    RAISE NOTICE '';
    RAISE NOTICE 'Tables loaded:';
    RAISE NOTICE '  - departments: % records', (SELECT COUNT(*) FROM departments);
    RAISE NOTICE '  - doctors: % records', (SELECT COUNT(*) FROM doctors);
    RAISE NOTICE '  - patients: % records', (SELECT COUNT(*) FROM patients);
    RAISE NOTICE '  - staff: % records', (SELECT COUNT(*) FROM staff);
    RAISE NOTICE '  - appointments: % records', (SELECT COUNT(*) FROM appointments);
    RAISE NOTICE '  - admissions: % records', (SELECT COUNT(*) FROM admissions);
    RAISE NOTICE '  - prescriptions: % records', (SELECT COUNT(*) FROM prescriptions);
    RAISE NOTICE '  - medical_tests: % records', (SELECT COUNT(*) FROM medical_tests);
    RAISE NOTICE '  - billing: % records', (SELECT COUNT(*) FROM billing);
    RAISE NOTICE '  - audit_log: % records', (SELECT COUNT(*) FROM audit_log);
    RAISE NOTICE '';
    RAISE NOTICE 'Database is ready for use!';
    RAISE NOTICE '================================================';
    RAISE NOTICE '';
END $$;

-- ================================================
-- End of Data Loading Script
-- ================================================
