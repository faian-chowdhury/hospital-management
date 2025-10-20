-- =====================================================
-- Hospital Management System - Supabase Data Insertion
-- =====================================================
-- Purpose: Insert sample data for all tables in Supabase environment
-- Total Records: 217
-- Deployment: Use Supabase SQL Editor
-- Author: FAIAN
-- Date: January 2025
-- =====================================================

-- Disable RLS temporarily for bulk insertion (will be re-enabled)
ALTER TABLE IF EXISTS departments DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS doctors DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS patients DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS staff DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS appointments DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS admissions DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS prescriptions DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS medical_tests DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS billing DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS audit_log DISABLE ROW LEVEL SECURITY;

-- =====================================================
-- SECTION 1: DEPARTMENTS (12 records)
-- =====================================================
-- Core hospital departments with leadership information

INSERT INTO departments (department_id, department_name, floor_number, phone_extension, department_head) VALUES
(1, 'Emergency Medicine', '1', '1000', 'Dr. Sarah Chen'),
(2, 'Cardiology', '3', '3000', 'Dr. Michael Torres'),
(3, 'Neurology', '4', '4000', 'Dr. Emily Washington'),
(4, 'Pediatrics', '2', '2000', 'Dr. James Miller'),
(5, 'Orthopedics', '5', '5000', 'Dr. Lisa Anderson'),
(6, 'Oncology', '6', '6000', 'Dr. Robert Kumar'),
(7, 'Radiology', 'B1', '7000', 'Dr. Patricia Lee'),
(8, 'Laboratory', 'B2', '8000', 'Dr. David Brown'),
(9, 'Surgery', '7', '9000', 'Dr. Jennifer White'),
(10, 'Internal Medicine', '3', '3500', 'Dr. William Johnson'),
(11, 'Obstetrics and Gynecology', '4', '4500', 'Dr. Maria Garcia'),
(12, 'Psychiatry', '8', '8500', 'Dr. Thomas Anderson');

-- =====================================================
-- SECTION 2: DOCTORS (20 records)
-- =====================================================
-- Medical staff with specializations and credentials

INSERT INTO doctors (doctor_id, first_name, last_name, specialization, department_id, license_number, phone, email, years_of_experience, consultation_fee) VALUES
(1, 'Sarah', 'Chen', 'Emergency Medicine', 1, 'MD-MA-45678', '617-555-0101', 's.chen@bostonhospital.org', 15, 250.00),
(2, 'Michael', 'Torres', 'Cardiologist', 2, 'MD-MA-45679', '617-555-0102', 'm.torres@bostonhospital.org', 20, 400.00),
(3, 'Emily', 'Washington', 'Neurologist', 3, 'MD-MA-45680', '617-555-0103', 'e.washington@bostonhospital.org', 12, 380.00),
(4, 'James', 'Miller', 'Pediatrician', 4, 'MD-MA-45681', '617-555-0104', 'j.miller@bostonhospital.org', 18, 200.00),
(5, 'Lisa', 'Anderson', 'Orthopedic Surgeon', 5, 'MD-MA-45682', '617-555-0105', 'l.anderson@bostonhospital.org', 22, 450.00),
(6, 'Robert', 'Kumar', 'Oncologist', 6, 'MD-MA-45683', '617-555-0106', 'r.kumar@bostonhospital.org', 25, 500.00),
(7, 'Patricia', 'Lee', 'Radiologist', 7, 'MD-MA-45684', '617-555-0107', 'p.lee@bostonhospital.org', 10, 300.00),
(8, 'David', 'Brown', 'Pathologist', 8, 'MD-MA-45685', '617-555-0108', 'd.brown@bostonhospital.org', 14, 280.00),
(9, 'Jennifer', 'White', 'General Surgeon', 9, 'MD-MA-45686', '617-555-0109', 'j.white@bostonhospital.org', 16, 420.00),
(10, 'William', 'Johnson', 'Internist', 10, 'MD-MA-45687', '617-555-0110', 'w.johnson@bostonhospital.org', 19, 320.00),
(11, 'Maria', 'Garcia', 'OB-GYN', 11, 'MD-MA-45688', '617-555-0111', 'm.garcia@bostonhospital.org', 13, 350.00),
(12, 'Thomas', 'Anderson', 'Psychiatrist', 12, 'MD-MA-45689', '617-555-0112', 't.anderson@bostonhospital.org', 11, 300.00),
(13, 'Rachel', 'Martinez', 'Emergency Medicine', 1, 'MD-MA-45690', '617-555-0113', 'r.martinez@bostonhospital.org', 8, 250.00),
(14, 'Daniel', 'Kim', 'Cardiologist', 2, 'MD-MA-45691', '617-555-0114', 'd.kim@bostonhospital.org', 17, 400.00),
(15, 'Amanda', 'Taylor', 'Pediatrician', 4, 'MD-MA-45692', '617-555-0115', 'a.taylor@bostonhospital.org', 9, 200.00),
(16, 'Christopher', 'Davis', 'Orthopedic Surgeon', 5, 'MD-MA-45693', '617-555-0116', 'c.davis@bostonhospital.org', 21, 450.00),
(17, 'Jessica', 'Wilson', 'Oncologist', 6, 'MD-MA-45694', '617-555-0117', 'j.wilson@bostonhospital.org', 15, 500.00),
(18, 'Kevin', 'Moore', 'Neurologist', 3, 'MD-MA-45695', '617-555-0118', 'k.moore@bostonhospital.org', 12, 380.00),
(19, 'Michelle', 'Clark', 'General Surgeon', 9, 'MD-MA-45696', '617-555-0119', 'm.clark@bostonhospital.org', 14, 420.00),
(20, 'Steven', 'Lewis', 'Internist', 10, 'MD-MA-45697', '617-555-0120', 's.lewis@bostonhospital.org', 16, 320.00);

-- =====================================================
-- SECTION 3: PATIENTS (25 records)
-- =====================================================
-- Patient demographic and contact information

INSERT INTO patients (patient_id, first_name, last_name, date_of_birth, gender, blood_type, phone, email, address, city, state, zip_code, emergency_contact_name, emergency_contact_phone, insurance_provider, insurance_policy_number) VALUES
(1, 'John', 'Smith', '1985-03-15', 'M', 'O+', '617-555-2001', 'john.smith@email.com', '123 Harvard St', 'Cambridge', 'MA', '02138', 'Jane Smith', '617-555-2002', 'Blue Cross', 'BC-123456'),
(2, 'Emily', 'Johnson', '1992-07-22', 'F', 'A+', '617-555-2003', 'emily.j@email.com', '456 MIT Ave', 'Cambridge', 'MA', '02139', 'Robert Johnson', '617-555-2004', 'Aetna', 'AE-234567'),
(3, 'Michael', 'Williams', '1978-11-30', 'M', 'B+', '617-555-2005', 'm.williams@email.com', '789 BU Drive', 'Boston', 'MA', '02215', 'Sarah Williams', '617-555-2006', 'United Healthcare', 'UH-345678'),
(4, 'Sarah', 'Brown', '1995-05-10', 'F', 'AB+', '617-555-2007', 'sarah.b@email.com', '321 Commonwealth', 'Boston', 'MA', '02116', 'David Brown', '617-555-2008', 'Cigna', 'CI-456789'),
(5, 'David', 'Jones', '1988-09-18', 'M', 'O-', '617-555-2009', 'd.jones@email.com', '654 Beacon St', 'Boston', 'MA', '02215', 'Lisa Jones', '617-555-2010', 'Blue Cross', 'BC-567890'),
(6, 'Lisa', 'Garcia', '1991-12-05', 'F', 'A-', '617-555-2011', 'lisa.g@email.com', '987 Mass Ave', 'Cambridge', 'MA', '02139', 'Carlos Garcia', '617-555-2012', 'Aetna', 'AE-678901'),
(7, 'Robert', 'Martinez', '1983-04-25', 'M', 'B-', '617-555-2013', 'r.martinez@email.com', '147 Newbury St', 'Boston', 'MA', '02116', 'Maria Martinez', '617-555-2014', 'United Healthcare', 'UH-789012'),
(8, 'Jennifer', 'Davis', '1997-08-14', 'F', 'AB-', '617-555-2015', 'jennifer.d@email.com', '258 Boylston St', 'Boston', 'MA', '02116', 'Thomas Davis', '617-555-2016', 'Cigna', 'CI-890123'),
(9, 'William', 'Rodriguez', '1980-01-20', 'M', 'O+', '617-555-2017', 'w.rodriguez@email.com', '369 Tremont St', 'Boston', 'MA', '02116', 'Ana Rodriguez', '617-555-2018', 'Blue Cross', 'BC-901234'),
(10, 'Amanda', 'Wilson', '1993-06-08', 'F', 'A+', '617-555-2019', 'amanda.w@email.com', '741 Huntington Ave', 'Boston', 'MA', '02115', 'James Wilson', '617-555-2020', 'Aetna', 'AE-012345'),
(11, 'James', 'Anderson', '1986-10-12', 'M', 'B+', '617-555-2021', 'j.anderson@email.com', '852 Stuart St', 'Boston', 'MA', '02116', 'Mary Anderson', '617-555-2022', 'United Healthcare', 'UH-123456'),
(12, 'Mary', 'Taylor', '1994-03-28', 'F', 'O-', '617-555-2023', 'mary.t@email.com', '963 Washington St', 'Boston', 'MA', '02111', 'Peter Taylor', '617-555-2024', 'Cigna', 'CI-234567'),
(13, 'Christopher', 'Thomas', '1989-07-07', 'M', 'A-', '617-555-2025', 'c.thomas@email.com', '159 Cambridge St', 'Boston', 'MA', '02114', 'Laura Thomas', '617-555-2026', 'Blue Cross', 'BC-345678'),
(14, 'Jessica', 'Moore', '1996-11-16', 'F', 'B-', '617-555-2027', 'jessica.m@email.com', '357 Salem St', 'Boston', 'MA', '02113', 'Mark Moore', '617-555-2028', 'Aetna', 'AE-456789'),
(15, 'Daniel', 'Jackson', '1982-02-03', 'M', 'AB+', '617-555-2029', 'd.jackson@email.com', '486 Hanover St', 'Boston', 'MA', '02113', 'Susan Jackson', '617-555-2030', 'United Healthcare', 'UH-567890'),
(16, 'Ashley', 'White', '1990-05-21', 'F', 'O+', '617-555-2031', 'ashley.w@email.com', '579 Atlantic Ave', 'Boston', 'MA', '02210', 'Kevin White', '617-555-2032', 'Cigna', 'CI-678901'),
(17, 'Matthew', 'Harris', '1987-09-09', 'M', 'A+', '617-555-2033', 'm.harris@email.com', '681 Seaport Blvd', 'Boston', 'MA', '02210', 'Rachel Harris', '617-555-2034', 'Blue Cross', 'BC-789012'),
(18, 'Lauren', 'Martin', '1998-12-30', 'F', 'B+', '617-555-2035', 'lauren.m@email.com', '792 Summer St', 'Boston', 'MA', '02210', 'Brian Martin', '617-555-2036', 'Aetna', 'AE-890123'),
(19, 'Joshua', 'Thompson', '1984-04-17', 'M', 'AB-', '617-555-2037', 'j.thompson@email.com', '814 Congress St', 'Boston', 'MA', '02210', 'Nicole Thompson', '617-555-2038', 'United Healthcare', 'UH-901234'),
(20, 'Nicole', 'Garcia', '1992-08-26', 'F', 'O-', '617-555-2039', 'nicole.g@email.com', '925 Federal St', 'Boston', 'MA', '02110', 'Joshua Garcia', '617-555-2040', 'Cigna', 'CI-012345'),
(21, 'Brandon', 'Martinez', '1979-01-11', 'M', 'A-', '617-555-2041', 'b.martinez@email.com', '136 Pearl St', 'Boston', 'MA', '02110', 'Victoria Martinez', '617-555-2042', 'Blue Cross', 'BC-111222'),
(22, 'Victoria', 'Robinson', '1995-06-19', 'F', 'B-', '617-555-2043', 'v.robinson@email.com', '247 High St', 'Boston', 'MA', '02110', 'Brandon Robinson', '617-555-2044', 'Aetna', 'AE-222333'),
(23, 'Tyler', 'Clark', '1988-10-27', 'M', 'O+', '617-555-2045', 'tyler.c@email.com', '358 Broad St', 'Boston', 'MA', '02109', 'Megan Clark', '617-555-2046', 'United Healthcare', 'UH-333444'),
(24, 'Megan', 'Lewis', '1993-03-05', 'F', 'A+', '617-555-2047', 'megan.l@email.com', '469 State St', 'Boston', 'MA', '02109', 'Tyler Lewis', '617-555-2048', 'Cigna', 'CI-444555'),
(25, 'Justin', 'Lee', '1986-07-13', 'M', 'B+', '617-555-2049', 'justin.l@email.com', '571 Commercial St', 'Boston', 'MA', '02109', 'Amanda Lee', '617-555-2050', 'Blue Cross', 'BC-555666');

-- =====================================================
-- SECTION 4: STAFF (15 records)
-- =====================================================
-- Non-physician hospital staff members

INSERT INTO staff (staff_id, first_name, last_name, role, department_id, phone, email, hire_date, salary, shift) VALUES
(1, 'Nancy', 'Williams', 'Head Nurse', 1, '617-555-3001', 'n.williams@bostonhospital.org', '2018-03-15', 75000.00, 'Day'),
(2, 'Robert', 'Johnson', 'Nurse', 1, '617-555-3002', 'r.johnson@bostonhospital.org', '2019-06-20', 65000.00, 'Night'),
(3, 'Linda', 'Brown', 'Nurse', 2, '617-555-3003', 'l.brown@bostonhospital.org', '2017-01-10', 68000.00, 'Day'),
(4, 'Patricia', 'Davis', 'Nurse', 3, '617-555-3004', 'p.davis@bostonhospital.org', '2020-02-14', 63000.00, 'Evening'),
(5, 'Michael', 'Miller', 'Nurse', 4, '617-555-3005', 'm.miller@bostonhospital.org', '2019-08-22', 65000.00, 'Day'),
(6, 'Barbara', 'Wilson', 'Radiologic Technologist', 7, '617-555-3006', 'b.wilson@bostonhospital.org', '2018-11-30', 70000.00, 'Day'),
(7, 'Elizabeth', 'Moore', 'Lab Technician', 8, '617-555-3007', 'e.moore@bostonhospital.org', '2017-05-18', 68000.00, 'Day'),
(8, 'Susan', 'Taylor', 'Medical Records Clerk', 10, '617-555-3008', 's.taylor@bostonhospital.org', '2016-09-12', 52000.00, 'Day'),
(9, 'Joseph', 'Anderson', 'Nurse', 9, '617-555-3009', 'j.anderson@bostonhospital.org', '2019-04-25', 67000.00, 'Day'),
(10, 'Margaret', 'Thomas', 'Nurse', 5, '617-555-3010', 'm.thomas@bostonhospital.org', '2018-07-08', 66000.00, 'Evening'),
(11, 'Dorothy', 'Jackson', 'Pharmacist', NULL, '617-555-3011', 'd.jackson@bostonhospital.org', '2017-03-20', 95000.00, 'Day'),
(12, 'Sarah', 'White', 'Nurse', 6, '617-555-3012', 's.white@bostonhospital.org', '2020-01-15', 64000.00, 'Day'),
(13, 'Charles', 'Harris', 'Physical Therapist', 5, '617-555-3013', 'c.harris@bostonhospital.org', '2018-10-10', 72000.00, 'Day'),
(14, 'Jessica', 'Martin', 'Nurse', 11, '617-555-3014', 'j.martin@bostonhospital.org', '2019-12-05', 65000.00, 'Day'),
(15, 'Kevin', 'Thompson', 'Respiratory Therapist', 1, '617-555-3015', 'k.thompson@bostonhospital.org', '2017-08-28', 71000.00, 'Night');

-- =====================================================
-- SECTION 5: APPOINTMENTS (30 records)
-- =====================================================
-- Patient-doctor consultation scheduling

INSERT INTO appointments (appointment_id, patient_id, doctor_id, appointment_date, appointment_time, status, reason, notes) VALUES
(1, 1, 1, '2025-10-01', '09:00:00', 'Completed', 'Chest pain', 'Patient treated for anxiety-related chest pain'),
(2, 2, 4, '2025-10-01', '10:00:00', 'Completed', 'Annual checkup', 'Routine pediatric examination'),
(3, 3, 2, '2025-10-01', '14:00:00', 'Completed', 'Heart palpitations', 'ECG performed - normal results'),
(4, 4, 11, '2025-10-02', '09:30:00', 'Completed', 'Prenatal visit', '20-week ultrasound scheduled'),
(5, 5, 5, '2025-10-02', '11:00:00', 'Completed', 'Knee pain', 'Possible meniscus tear - MRI ordered'),
(6, 6, 6, '2025-10-02', '15:00:00', 'Completed', 'Follow-up consultation', 'Chemotherapy cycle 3 completed'),
(7, 7, 9, '2025-10-03', '08:00:00', 'Completed', 'Pre-operative consultation', 'Appendectomy scheduled for next week'),
(8, 8, 12, '2025-10-03', '13:00:00', 'Completed', 'Anxiety and depression', 'Medication adjustment needed'),
(9, 9, 3, '2025-10-04', '10:30:00', 'Completed', 'Migraine headaches', 'MRI scheduled to rule out serious causes'),
(10, 10, 4, '2025-10-04', '14:00:00', 'Completed', 'Child vaccination', 'MMR vaccine administered'),
(11, 11, 10, '2025-10-05', '09:00:00', 'Completed', 'Diabetes management', 'A1C test ordered'),
(12, 12, 1, '2025-10-05', '16:00:00', 'Completed', 'Severe abdominal pain', 'Appendicitis suspected - admitted'),
(13, 13, 2, '2025-10-06', '10:00:00', 'Completed', 'Chest pain', 'Stress test scheduled'),
(14, 14, 5, '2025-10-06', '11:30:00', 'Completed', 'Shoulder injury', 'Rotator cuff strain diagnosed'),
(15, 15, 6, '2025-10-07', '13:00:00', 'Completed', 'Cancer screening', 'Colonoscopy scheduled'),
(16, 16, 11, '2025-10-07', '09:30:00', 'Completed', 'Pregnancy confirmation', '8 weeks pregnant'),
(17, 17, 3, '2025-10-08', '14:30:00', 'Completed', 'Numbness in hands', 'Carpal tunnel syndrome suspected'),
(18, 18, 4, '2025-10-08', '10:00:00', 'Completed', 'Fever and cough', 'Viral infection - symptomatic treatment'),
(19, 19, 9, '2025-10-09', '08:30:00', 'Scheduled', 'Hernia repair consultation', 'Inguinal hernia evaluation'),
(20, 20, 12, '2025-10-09', '15:00:00', 'Scheduled', 'Depression screening', 'Initial psychiatric evaluation'),
(21, 1, 10, '2025-10-10', '09:00:00', 'Scheduled', 'Follow-up', 'Post-ER follow-up'),
(22, 3, 14, '2025-10-10', '11:00:00', 'Scheduled', 'Cardiology follow-up', 'Review ECG and stress test results'),
(23, 5, 16, '2025-10-11', '10:00:00', 'Scheduled', 'Orthopedic follow-up', 'Review MRI results'),
(24, 9, 18, '2025-10-11', '13:00:00', 'Scheduled', 'Neurology follow-up', 'MRI results discussion'),
(25, 11, 20, '2025-10-12', '09:30:00', 'Scheduled', 'Diabetes follow-up', 'Review A1C results'),
(26, 2, 15, '2025-10-12', '14:00:00', 'Scheduled', '6-month checkup', 'Routine pediatric examination'),
(27, 6, 17, '2025-10-13', '10:00:00', 'Scheduled', 'Oncology follow-up', 'Chemotherapy cycle 4 planning'),
(28, 7, 19, '2025-10-13', '15:00:00', 'Scheduled', 'Post-operative follow-up', 'Appendectomy recovery check'),
(29, 13, 2, '2025-10-14', '11:00:00', 'Scheduled', 'Stress test', 'Cardiac stress test appointment'),
(30, 15, 6, '2025-10-14', '09:00:00', 'Scheduled', 'Colonoscopy', 'Cancer screening procedure');

-- =====================================================
-- SECTION 6: ADMISSIONS (15 records)
-- =====================================================
-- Inpatient hospital stays and room assignments

INSERT INTO admissions (admission_id, patient_id, admission_date, discharge_date, room_number, bed_number, admission_type, discharge_status, primary_diagnosis, attending_doctor_id) VALUES
(1, 12, '2025-10-05', '2025-10-07', '301', 'A', 'Emergency', 'Discharged', 'Acute appendicitis', 9),
(2, 6, '2025-09-15', '2025-09-20', '502', 'B', 'Planned', 'Discharged', 'Chemotherapy treatment', 6),
(3, 5, '2025-09-22', '2025-09-25', '401', 'A', 'Emergency', 'Discharged', 'Meniscus tear repair', 5),
(4, 16, '2025-09-28', '2025-10-02', '304', 'C', 'Planned', 'Discharged', 'Normal delivery', 11),
(5, 3, '2025-10-01', '2025-10-03', '201', 'B', 'Emergency', 'Discharged', 'Acute myocardial infarction', 2),
(6, 9, '2025-10-04', NULL, '405', 'A', 'Emergency', 'Admitted', 'Severe migraine investigation', 3),
(7, 7, '2025-10-08', NULL, '601', 'B', 'Planned', 'Admitted', 'Appendectomy preparation', 9),
(8, 1, '2025-10-05', '2025-10-05', '101', 'A', 'Emergency', 'Discharged', 'Panic attack', 1),
(9, 14, '2025-09-18', '2025-09-22', '402', 'C', 'Emergency', 'Discharged', 'Shoulder dislocation', 5),
(10, 19, '2025-09-25', '2025-09-28', '603', 'A', 'Planned', 'Discharged', 'Hernia repair', 9),
(11, 8, '2025-09-10', '2025-09-15', '701', 'B', 'Planned', 'Discharged', 'Psychiatric evaluation', 12),
(12, 13, '2025-09-20', '2025-09-23', '202', 'A', 'Emergency', 'Discharged', 'Unstable angina', 14),
(13, 4, '2025-09-29', '2025-10-01', '305', 'B', 'Emergency', 'Discharged', 'Hyperemesis gravidarum', 11),
(14, 17, '2025-10-02', '2025-10-04', '403', 'C', 'Emergency', 'Discharged', 'Carpal tunnel surgery', 5),
(15, 15, '2025-10-06', '2025-10-08', '501', 'A', 'Planned', 'Discharged', 'Colonoscopy', 6);

-- =====================================================
-- SECTION 7: PRESCRIPTIONS (25 records)
-- =====================================================
-- Medication prescriptions with dosage instructions

INSERT INTO prescriptions (prescription_id, patient_id, doctor_id, medication_name, dosage, frequency, duration_days, start_date, end_date, refills_allowed, instructions) VALUES
(1, 1, 1, 'Alprazolam', '0.5mg', 'Twice daily', 30, '2025-10-01', '2025-10-31', 2, 'Take with food'),
(2, 2, 4, 'Amoxicillin', '250mg', 'Three times daily', 10, '2025-10-01', '2025-10-11', 0, 'Complete full course'),
(3, 3, 2, 'Atorvastatin', '20mg', 'Once daily', 90, '2025-10-01', '2025-12-30', 3, 'Take at bedtime'),
(4, 4, 11, 'Prenatal vitamins', '1 tablet', 'Once daily', 90, '2025-10-02', '2025-12-31', 3, 'Take with food'),
(5, 5, 5, 'Ibuprofen', '600mg', 'As needed', 30, '2025-10-02', '2025-11-01', 1, 'Take with food - max 3 times daily'),
(6, 6, 6, 'Ondansetron', '8mg', 'Three times daily', 30, '2025-10-02', '2025-11-01', 2, 'For nausea during chemotherapy'),
(7, 7, 9, 'Ciprofloxacin', '500mg', 'Twice daily', 7, '2025-10-03', '2025-10-10', 0, 'Take on empty stomach'),
(8, 8, 12, 'Sertraline', '50mg', 'Once daily', 90, '2025-10-03', '2025-12-31', 3, 'Take in the morning'),
(9, 9, 3, 'Sumatriptan', '50mg', 'As needed', 30, '2025-10-04', '2025-11-03', 2, 'Take at onset of migraine'),
(10, 10, 4, 'MMR Vaccine', '1 dose', 'Single dose', 0, '2025-10-04', '2025-10-04', 0, 'Vaccination record'),
(11, 11, 10, 'Metformin', '500mg', 'Twice daily', 90, '2025-10-05', '2025-12-31', 3, 'Take with meals'),
(12, 12, 9, 'Morphine', '10mg', 'Every 4-6 hours', 3, '2025-10-05', '2025-10-08', 0, 'Post-operative pain management'),
(13, 13, 2, 'Nitroglycerin', '0.4mg', 'As needed', 30, '2025-10-06', '2025-11-05', 2, 'Sublingual for chest pain'),
(14, 14, 5, 'Naproxen', '500mg', 'Twice daily', 14, '2025-10-06', '2025-10-20', 0, 'Take with food'),
(15, 15, 6, 'Polyethylene glycol', '17g', 'Per protocol', 1, '2025-10-07', '2025-10-08', 0, 'For colonoscopy prep'),
(16, 16, 11, 'Folic acid', '1mg', 'Once daily', 90, '2025-10-07', '2025-12-31', 3, 'Take in the morning'),
(17, 17, 3, 'Gabapentin', '300mg', 'Three times daily', 60, '2025-10-08', '2025-12-07', 2, 'May cause drowsiness'),
(18, 18, 4, 'Acetaminophen', '325mg', 'Every 6 hours', 7, '2025-10-08', '2025-10-15', 0, 'For fever reduction'),
(19, 3, 2, 'Aspirin', '81mg', 'Once daily', 90, '2025-10-01', '2025-12-30', 3, 'Take with food'),
(20, 11, 10, 'Glipizide', '5mg', 'Once daily', 90, '2025-10-05', '2025-12-31', 3, 'Take before breakfast'),
(21, 6, 6, 'Dexamethasone', '4mg', 'Twice daily', 5, '2025-10-02', '2025-10-07', 0, 'Chemotherapy side effect management'),
(22, 8, 12, 'Buspirone', '10mg', 'Twice daily', 90, '2025-10-03', '2025-12-31', 3, 'For anxiety'),
(23, 5, 5, 'Cyclobenzaprine', '10mg', 'At bedtime', 14, '2025-10-02', '2025-10-16', 0, 'Muscle relaxant'),
(24, 9, 3, 'Propranolol', '40mg', 'Twice daily', 90, '2025-10-04', '2025-12-31', 3, 'Migraine prevention'),
(25, 12, 9, 'Docusate', '100mg', 'Twice daily', 7, '2025-10-05', '2025-10-12', 0, 'Stool softener post-surgery');

-- =====================================================
-- SECTION 8: MEDICAL_TESTS (30 records)
-- =====================================================
-- Diagnostic tests and laboratory results

INSERT INTO medical_tests (test_id, patient_id, doctor_id, test_type, test_name, test_date, status, results, notes) VALUES
(1, 3, 2, 'Blood Test', 'Lipid Panel', '2025-10-01', 'Completed', 'Total Cholesterol: 240 mg/dL (High)', 'Recommend statin therapy'),
(2, 4, 11, 'Imaging', 'Ultrasound - Prenatal', '2025-10-02', 'Completed', 'Normal fetal development at 20 weeks', 'Next ultrasound at 32 weeks'),
(3, 5, 5, 'Imaging', 'MRI - Knee', '2025-10-03', 'Completed', 'Medial meniscus tear confirmed', 'Surgery recommended'),
(4, 9, 3, 'Imaging', 'MRI - Brain', '2025-10-05', 'Scheduled', 'Pending', 'To rule out structural causes'),
(5, 11, 10, 'Blood Test', 'HbA1c', '2025-10-05', 'Completed', '8.2% (Poor control)', 'Medication adjustment needed'),
(6, 12, 9, 'Blood Test', 'Complete Blood Count', '2025-10-05', 'Completed', 'WBC: 15000 (Elevated)', 'Consistent with infection'),
(7, 13, 2, 'Diagnostic', 'ECG - 12 Lead', '2025-10-06', 'Completed', 'ST-segment depression', 'Stress test recommended'),
(8, 13, 2, 'Diagnostic', 'Cardiac Stress Test', '2025-10-14', 'Scheduled', 'Pending', 'Scheduled for next week'),
(9, 15, 6, 'Procedure', 'Colonoscopy', '2025-10-14', 'Scheduled', 'Pending', 'Prep instructions provided'),
(10, 1, 1, 'Blood Test', 'Complete Blood Count', '2025-10-01', 'Completed', 'All values normal', 'No abnormalities detected'),
(11, 2, 4, 'Blood Test', 'Complete Blood Count', '2025-10-01', 'Completed', 'All values normal', 'Routine pediatric screening'),
(12, 6, 6, 'Blood Test', 'Tumor Markers', '2025-10-02', 'Completed', 'CEA: Stable', 'Continue current treatment'),
(13, 7, 9, 'Imaging', 'CT Scan - Abdomen', '2025-10-03', 'Completed', 'Inflamed appendix confirmed', 'Surgery indicated'),
(14, 8, 12, 'Blood Test', 'Comprehensive Metabolic Panel', '2025-10-03', 'Completed', 'All values within normal range', 'Continue current medications'),
(15, 10, 4, 'Immunization', 'MMR Titer', '2025-10-04', 'Completed', 'Immunity confirmed', 'Vaccine effective'),
(16, 14, 5, 'Imaging', 'X-Ray - Shoulder', '2025-10-06', 'Completed', 'No fracture detected', 'Soft tissue injury'),
(17, 16, 11, 'Blood Test', 'Beta-hCG', '2025-10-07', 'Completed', 'Pregnancy confirmed', 'Levels consistent with 8 weeks'),
(18, 17, 3, 'Diagnostic', 'Nerve Conduction Study', '2025-10-09', 'Scheduled', 'Pending', 'To confirm carpal tunnel diagnosis'),
(19, 18, 4, 'Blood Test', 'Rapid Strep Test', '2025-10-08', 'Completed', 'Negative', 'Viral etiology likely'),
(20, 3, 2, 'Imaging', 'Echocardiogram', '2025-10-02', 'Completed', 'Mild left ventricular dysfunction', 'Follow-up in 6 months'),
(21, 5, 5, 'Imaging', 'X-Ray - Knee', '2025-10-02', 'Completed', 'No bone abnormalities', 'MRI needed for soft tissue'),
(22, 11, 10, 'Blood Test', 'Fasting Glucose', '2025-10-05', 'Completed', '165 mg/dL (Elevated)', 'Continue diabetes management'),
(23, 12, 9, 'Imaging', 'CT Scan - Abdomen', '2025-10-05', 'Completed', 'Acute appendicitis confirmed', 'Emergency surgery required'),
(24, 6, 6, 'Imaging', 'PET Scan', '2025-09-20', 'Completed', 'Partial response to chemotherapy', 'Continue current regimen'),
(25, 9, 3, 'Blood Test', 'Complete Blood Count', '2025-10-04', 'Completed', 'All values normal', 'Migraine not related to blood disorder'),
(26, 4, 11, 'Blood Test', 'Complete Blood Count', '2025-10-02', 'Completed', 'Mild anemia', 'Iron supplementation recommended'),
(27, 15, 6, 'Blood Test', 'Carcinoembryonic Antigen', '2025-10-07', 'Completed', 'Within normal limits', 'Screening only'),
(28, 1, 1, 'Diagnostic', 'ECG - 12 Lead', '2025-10-01', 'Completed', 'Normal sinus rhythm', 'Anxiety-related chest pain confirmed'),
(29, 7, 9, 'Blood Test', 'Complete Blood Count', '2025-10-08', 'Completed', 'Post-op values normal', 'Recovery progressing well'),
(30, 13, 14, 'Diagnostic', 'ECG - 12 Lead', '2025-10-06', 'Completed', 'Borderline abnormal', 'Stress test needed');

-- =====================================================
-- SECTION 9: BILLING (30 records)
-- =====================================================
-- Financial transactions and insurance claims

INSERT INTO billing (billing_id, patient_id, appointment_id, admission_id, bill_date, total_amount, insurance_covered, patient_responsibility, payment_status, payment_date, payment_method) VALUES
(1, 1, 1, NULL, '2025-10-01', 350.00, 280.00, 70.00, 'Paid', '2025-10-01', 'Credit Card'),
(2, 2, 2, NULL, '2025-10-01', 200.00, 180.00, 20.00, 'Paid', '2025-10-01', 'Insurance'),
(3, 3, 3, NULL, '2025-10-01', 450.00, 360.00, 90.00, 'Paid', '2025-10-02', 'Debit Card'),
(4, 4, 4, NULL, '2025-10-02', 350.00, 315.00, 35.00, 'Paid', '2025-10-02', 'Insurance'),
(5, 5, 5, NULL, '2025-10-02', 550.00, 440.00, 110.00, 'Pending', NULL, NULL),
(6, 6, 6, NULL, '2025-10-02', 500.00, 450.00, 50.00, 'Paid', '2025-10-03', 'Insurance'),
(7, 7, 7, NULL, '2025-10-03', 420.00, 336.00, 84.00, 'Paid', '2025-10-03', 'Credit Card'),
(8, 8, 8, NULL, '2025-10-03', 300.00, 240.00, 60.00, 'Paid', '2025-10-04', 'Insurance'),
(9, 9, 9, NULL, '2025-10-04', 480.00, 384.00, 96.00, 'Pending', NULL, NULL),
(10, 10, 10, NULL, '2025-10-04', 250.00, 225.00, 25.00, 'Paid', '2025-10-04', 'Insurance'),
(11, 11, 11, NULL, '2025-10-05', 320.00, 256.00, 64.00, 'Paid', '2025-10-05', 'Debit Card'),
(12, 12, 12, 1, '2025-10-07', 15750.00, 14175.00, 1575.00, 'Paid', '2025-10-08', 'Insurance'),
(13, 13, 13, NULL, '2025-10-06', 400.00, 320.00, 80.00, 'Paid', '2025-10-06', 'Credit Card'),
(14, 14, 14, NULL, '2025-10-06', 450.00, 360.00, 90.00, 'Pending', NULL, NULL),
(15, 15, 15, NULL, '2025-10-07', 500.00, 450.00, 50.00, 'Paid', '2025-10-07', 'Insurance'),
(16, 16, 16, NULL, '2025-10-07', 350.00, 315.00, 35.00, 'Paid', '2025-10-07', 'Insurance'),
(17, 17, 17, NULL, '2025-10-08', 380.00, 304.00, 76.00, 'Paid', '2025-10-08', 'Debit Card'),
(18, 18, 18, NULL, '2025-10-08', 200.00, 180.00, 20.00, 'Paid', '2025-10-08', 'Insurance'),
(19, 6, NULL, 2, '2025-09-20', 25600.00, 23040.00, 2560.00, 'Paid', '2025-09-25', 'Insurance'),
(20, 5, NULL, 3, '2025-09-25', 18900.00, 17010.00, 1890.00, 'Paid', '2025-09-30', 'Insurance'),
(21, 16, NULL, 4, '2025-10-02', 12400.00, 11160.00, 1240.00, 'Paid', '2025-10-05', 'Insurance'),
(22, 3, NULL, 5, '2025-10-03', 32500.00, 29250.00, 3250.00, 'Paid', '2025-10-10', 'Insurance'),
(23, 9, NULL, 6, '2025-10-04', 8500.00, 7650.00, 850.00, 'Pending', NULL, NULL),
(24, 7, NULL, 7, '2025-10-08', 3200.00, 2880.00, 320.00, 'Pending', NULL, NULL),
(25, 1, NULL, 8, '2025-10-05', 2100.00, 1680.00, 420.00, 'Paid', '2025-10-05', 'Credit Card'),
(26, 14, NULL, 9, '2025-09-22', 14300.00, 12870.00, 1430.00, 'Paid', '2025-09-28', 'Insurance'),
(27, 19, NULL, 10, '2025-09-28', 16800.00, 15120.00, 1680.00, 'Paid', '2025-10-03', 'Insurance'),
(28, 8, NULL, 11, '2025-09-15', 9500.00, 8550.00, 950.00, 'Paid', '2025-09-20', 'Insurance'),
(29, 13, NULL, 12, '2025-09-23', 22400.00, 20160.00, 2240.00, 'Paid', '2025-09-28', 'Insurance'),
(30, 4, NULL, 13, '2025-10-01', 6750.00, 6075.00, 675.00, 'Paid', '2025-10-03', 'Insurance');

-- =====================================================
-- SECTION 10: AUDIT_LOG (15 records)
-- =====================================================
-- System audit trail for data modifications

INSERT INTO audit_log (log_id, table_name, operation, record_id, changed_by, changed_at, old_data, new_data) VALUES
(1, 'patients', 'INSERT', 1, 'system', '2025-09-15 10:30:00', NULL, '{"first_name":"John","last_name":"Smith"}'),
(2, 'appointments', 'INSERT', 1, 'doctor_1', '2025-09-28 14:20:00', NULL, '{"patient_id":1,"doctor_id":1,"date":"2025-10-01"}'),
(3, 'appointments', 'UPDATE', 1, 'doctor_1', '2025-10-01 09:45:00', '{"status":"Scheduled"}', '{"status":"Completed"}'),
(4, 'prescriptions', 'INSERT', 1, 'doctor_1', '2025-10-01 10:00:00', NULL, '{"patient_id":1,"medication":"Alprazolam"}'),
(5, 'admissions', 'INSERT', 1, 'doctor_9', '2025-10-05 18:30:00', NULL, '{"patient_id":12,"diagnosis":"Acute appendicitis"}'),
(6, 'billing', 'INSERT', 12, 'billing_admin', '2025-10-07 09:15:00', NULL, '{"patient_id":12,"amount":15750.00}'),
(7, 'admissions', 'UPDATE', 1, 'doctor_9', '2025-10-07 11:00:00', '{"discharge_date":null}', '{"discharge_date":"2025-10-07"}'),
(8, 'patients', 'UPDATE', 6, 'admin', '2025-10-02 13:45:00', '{"phone":"617-555-2011"}', '{"phone":"617-555-2099"}'),
(9, 'doctors', 'UPDATE', 2, 'hr_admin', '2025-10-01 08:00:00', '{"consultation_fee":380.00}', '{"consultation_fee":400.00}'),
(10, 'medical_tests', 'INSERT', 1, 'lab_tech', '2025-10-01 16:30:00', NULL, '{"patient_id":3,"test_type":"Blood Test"}'),
(11, 'appointments', 'DELETE', 25, 'admin', '2025-10-08 10:15:00', '{"patient_id":11,"status":"Cancelled"}', NULL),
(12, 'prescriptions', 'UPDATE', 8, 'doctor_12', '2025-10-03 15:20:00', '{"dosage":"25mg"}', '{"dosage":"50mg"}'),
(13, 'staff', 'INSERT', 1, 'hr_admin', '2025-09-01 09:00:00', NULL, '{"first_name":"Nancy","role":"Head Nurse"}'),
(14, 'billing', 'UPDATE', 5, 'billing_admin', '2025-10-09 14:30:00', '{"payment_status":"Pending"}', '{"payment_status":"Paid"}'),
(15, 'medical_tests', 'UPDATE', 4, 'doctor_3', '2025-10-05 11:00:00', '{"status":"Pending"}', '{"status":"Scheduled"}');

-- =====================================================
-- DATA INSERTION COMPLETE
-- =====================================================
-- Total Records Inserted: 217
-- - Departments: 12
-- - Doctors: 20
-- - Patients: 25
-- - Staff: 15
-- - Appointments: 30
-- - Admissions: 15
-- - Prescriptions: 25
-- - Medical Tests: 30
-- - Billing: 30
-- - Audit Log: 15
-- =====================================================

-- Re-enable RLS on all tables
ALTER TABLE departments ENABLE ROW LEVEL SECURITY;
ALTER TABLE doctors ENABLE ROW LEVEL SECURITY;
ALTER TABLE patients ENABLE ROW LEVEL SECURITY;
ALTER TABLE staff ENABLE ROW LEVEL SECURITY;
ALTER TABLE appointments ENABLE ROW LEVEL SECURITY;
ALTER TABLE admissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE prescriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE medical_tests ENABLE ROW LEVEL SECURITY;
ALTER TABLE billing ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_log ENABLE ROW LEVEL SECURITY;

-- Verify data insertion
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

-- =====================================================
-- END OF FILE
-- =====================================================
