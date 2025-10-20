-- ================================================
-- Hospital Management System - Database Schema
-- Student: FAIAN
-- Option 3: Coding-Heavy DBA / DevOps Project
-- Date: October 9, 2025
-- ================================================

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ================================================
-- TABLE 1: departments
-- Purpose: Hospital departments and organizational structure
-- ================================================

CREATE TABLE departments (
    department_id SERIAL PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL UNIQUE,
    floor_number VARCHAR(10) NOT NULL,
    phone_extension VARCHAR(10) NOT NULL,
    department_head VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT chk_department_name CHECK (LENGTH(department_name) >= 3),
    CONSTRAINT chk_phone_extension CHECK (phone_extension ~ '^\d{4,10}$')
);

CREATE INDEX idx_departments_name ON departments(department_name);
CREATE INDEX idx_departments_floor ON departments(floor_number);

COMMENT ON TABLE departments IS 'Hospital departments and organizational structure';
COMMENT ON COLUMN departments.floor_number IS 'Floor location (can include basement levels like B1, B2)';

-- ================================================
-- TABLE 2: doctors
-- Purpose: Medical professionals and their credentials
-- ================================================

CREATE TABLE doctors (
    doctor_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    specialization VARCHAR(100) NOT NULL,
    department_id INTEGER NOT NULL,
    license_number VARCHAR(20) NOT NULL UNIQUE,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    years_of_experience INTEGER NOT NULL,
    consultation_fee DECIMAL(10, 2) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_doctor_department FOREIGN KEY (department_id) 
        REFERENCES departments(department_id) ON DELETE RESTRICT,
    CONSTRAINT chk_doctor_name CHECK (LENGTH(first_name) >= 2 AND LENGTH(last_name) >= 2),
    CONSTRAINT chk_license_format CHECK (license_number ~ '^MD-[A-Z]{2}-\d{5}$'),
    CONSTRAINT chk_doctor_email CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$'),
    CONSTRAINT chk_experience CHECK (years_of_experience >= 0 AND years_of_experience <= 50),
    CONSTRAINT chk_consultation_fee CHECK (consultation_fee >= 0 AND consultation_fee <= 10000)
);

CREATE INDEX idx_doctors_name ON doctors(last_name, first_name);
CREATE INDEX idx_doctors_specialization ON doctors(specialization);
CREATE INDEX idx_doctors_department ON doctors(department_id);
CREATE INDEX idx_doctors_email ON doctors(email);

COMMENT ON TABLE doctors IS 'Medical professionals with credentials and specializations';
COMMENT ON COLUMN doctors.license_number IS 'State medical license in format MD-STATE-XXXXX';

-- ================================================
-- TABLE 3: patients
-- Purpose: Patient demographics and insurance information
-- ================================================

CREATE TABLE patients (
    patient_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender CHAR(1) NOT NULL,
    blood_type VARCHAR(5) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(100),
    address VARCHAR(200) NOT NULL,
    city VARCHAR(50) NOT NULL,
    state CHAR(2) NOT NULL,
    zip_code VARCHAR(10) NOT NULL,
    emergency_contact_name VARCHAR(100) NOT NULL,
    emergency_contact_phone VARCHAR(20) NOT NULL,
    insurance_provider VARCHAR(100) NOT NULL,
    insurance_policy_number VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT chk_patient_name CHECK (LENGTH(first_name) >= 2 AND LENGTH(last_name) >= 2),
    CONSTRAINT chk_dob CHECK (date_of_birth < CURRENT_DATE AND date_of_birth > '1900-01-01'),
    CONSTRAINT chk_gender CHECK (gender IN ('M', 'F', 'O')),
    CONSTRAINT chk_blood_type CHECK (blood_type IN ('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-')),
    CONSTRAINT chk_patient_email CHECK (email IS NULL OR email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$'),
    CONSTRAINT chk_state CHECK (LENGTH(state) = 2),
    CONSTRAINT chk_zip_code CHECK (zip_code ~ '^\d{5}(-\d{4})?$')
);

CREATE INDEX idx_patients_name ON patients(last_name, first_name);
CREATE INDEX idx_patients_dob ON patients(date_of_birth);
CREATE INDEX idx_patients_blood_type ON patients(blood_type);
CREATE INDEX idx_patients_email ON patients(email);
CREATE INDEX idx_patients_insurance ON patients(insurance_provider);

COMMENT ON TABLE patients IS 'Patient demographics and insurance information';
COMMENT ON COLUMN patients.blood_type IS 'ABO and Rh blood type classification';

-- ================================================
-- TABLE 4: appointments
-- Purpose: Scheduled patient appointments with doctors
-- ================================================

CREATE TABLE appointments (
    appointment_id SERIAL PRIMARY KEY,
    patient_id INTEGER NOT NULL,
    doctor_id INTEGER NOT NULL,
    appointment_date DATE NOT NULL,
    appointment_time TIME NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'Scheduled',
    reason VARCHAR(500) NOT NULL,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_appointment_patient FOREIGN KEY (patient_id) 
        REFERENCES patients(patient_id) ON DELETE CASCADE,
    CONSTRAINT fk_appointment_doctor FOREIGN KEY (doctor_id) 
        REFERENCES doctors(doctor_id) ON DELETE RESTRICT,
    CONSTRAINT chk_appointment_date CHECK (appointment_date >= CURRENT_DATE - INTERVAL '1 year'),
    CONSTRAINT chk_status CHECK (status IN ('Scheduled', 'Completed', 'Cancelled', 'No-Show')),
    CONSTRAINT chk_reason CHECK (LENGTH(reason) >= 5)
);

CREATE INDEX idx_appointments_patient ON appointments(patient_id);
CREATE INDEX idx_appointments_doctor ON appointments(doctor_id);
CREATE INDEX idx_appointments_date ON appointments(appointment_date);
CREATE INDEX idx_appointments_status ON appointments(status);
CREATE INDEX idx_appointments_datetime ON appointments(appointment_date, appointment_time);

COMMENT ON TABLE appointments IS 'Scheduled patient appointments with doctors';
COMMENT ON COLUMN appointments.status IS 'Appointment status: Scheduled, Completed, Cancelled, No-Show';

-- ================================================
-- TABLE 5: admissions
-- Purpose: Hospital admissions and inpatient stays
-- ================================================

CREATE TABLE admissions (
    admission_id SERIAL PRIMARY KEY,
    patient_id INTEGER NOT NULL,
    admission_date DATE NOT NULL,
    discharge_date DATE,
    room_number VARCHAR(10) NOT NULL,
    bed_number CHAR(1) NOT NULL,
    admission_type VARCHAR(20) NOT NULL,
    discharge_status VARCHAR(20),
    primary_diagnosis VARCHAR(500) NOT NULL,
    attending_doctor_id INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_admission_patient FOREIGN KEY (patient_id) 
        REFERENCES patients(patient_id) ON DELETE CASCADE,
    CONSTRAINT fk_admission_doctor FOREIGN KEY (attending_doctor_id) 
        REFERENCES doctors(doctor_id) ON DELETE RESTRICT,
    CONSTRAINT chk_admission_dates CHECK (
        discharge_date IS NULL OR discharge_date >= admission_date
    ),
    CONSTRAINT chk_admission_type CHECK (admission_type IN ('Emergency', 'Planned', 'Transfer')),
    CONSTRAINT chk_discharge_status CHECK (
        discharge_status IS NULL OR 
        discharge_status IN ('Discharged', 'Transferred', 'Deceased', 'Admitted', 'Left AMA')
    ),
    CONSTRAINT chk_bed_number CHECK (bed_number ~ '^[A-Z]$'),
    CONSTRAINT chk_diagnosis CHECK (LENGTH(primary_diagnosis) >= 5)
);

CREATE INDEX idx_admissions_patient ON admissions(patient_id);
CREATE INDEX idx_admissions_doctor ON admissions(attending_doctor_id);
CREATE INDEX idx_admissions_date ON admissions(admission_date);
CREATE INDEX idx_admissions_discharge ON admissions(discharge_date);
CREATE INDEX idx_admissions_room ON admissions(room_number);
CREATE INDEX idx_admissions_status ON admissions(discharge_status);

COMMENT ON TABLE admissions IS 'Hospital admissions and inpatient stays';
COMMENT ON COLUMN admissions.discharge_status IS 'NULL for currently admitted patients';

-- ================================================
-- TABLE 6: prescriptions
-- Purpose: Medications prescribed to patients
-- ================================================

CREATE TABLE prescriptions (
    prescription_id SERIAL PRIMARY KEY,
    patient_id INTEGER NOT NULL,
    doctor_id INTEGER NOT NULL,
    medication_name VARCHAR(200) NOT NULL,
    dosage VARCHAR(50) NOT NULL,
    frequency VARCHAR(100) NOT NULL,
    duration_days INTEGER NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    refills_allowed INTEGER NOT NULL DEFAULT 0,
    instructions TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_prescription_patient FOREIGN KEY (patient_id) 
        REFERENCES patients(patient_id) ON DELETE CASCADE,
    CONSTRAINT fk_prescription_doctor FOREIGN KEY (doctor_id) 
        REFERENCES doctors(doctor_id) ON DELETE RESTRICT,
    CONSTRAINT chk_prescription_dates CHECK (end_date >= start_date),
    CONSTRAINT chk_duration CHECK (duration_days >= 0 AND duration_days <= 365),
    CONSTRAINT chk_refills CHECK (refills_allowed >= 0 AND refills_allowed <= 12),
    CONSTRAINT chk_medication CHECK (LENGTH(medication_name) >= 3)
);

CREATE INDEX idx_prescriptions_patient ON prescriptions(patient_id);
CREATE INDEX idx_prescriptions_doctor ON prescriptions(doctor_id);
CREATE INDEX idx_prescriptions_medication ON prescriptions(medication_name);
CREATE INDEX idx_prescriptions_dates ON prescriptions(start_date, end_date);

COMMENT ON TABLE prescriptions IS 'Medications prescribed to patients';
COMMENT ON COLUMN prescriptions.refills_allowed IS 'Number of times prescription can be refilled';

-- ================================================
-- TABLE 7: medical_tests
-- Purpose: Laboratory and diagnostic tests
-- ================================================

CREATE TABLE medical_tests (
    test_id SERIAL PRIMARY KEY,
    patient_id INTEGER NOT NULL,
    doctor_id INTEGER NOT NULL,
    test_type VARCHAR(50) NOT NULL,
    test_name VARCHAR(200) NOT NULL,
    test_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'Pending',
    results TEXT,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_test_patient FOREIGN KEY (patient_id) 
        REFERENCES patients(patient_id) ON DELETE CASCADE,
    CONSTRAINT fk_test_doctor FOREIGN KEY (doctor_id) 
        REFERENCES doctors(doctor_id) ON DELETE RESTRICT,
    CONSTRAINT chk_test_type CHECK (test_type IN ('Blood Test', 'Imaging', 'Diagnostic', 'Procedure', 'Immunization')),
    CONSTRAINT chk_test_status CHECK (status IN ('Pending', 'Scheduled', 'In Progress', 'Completed', 'Cancelled')),
    CONSTRAINT chk_test_name CHECK (LENGTH(test_name) >= 3)
);

CREATE INDEX idx_tests_patient ON medical_tests(patient_id);
CREATE INDEX idx_tests_doctor ON medical_tests(doctor_id);
CREATE INDEX idx_tests_type ON medical_tests(test_type);
CREATE INDEX idx_tests_date ON medical_tests(test_date);
CREATE INDEX idx_tests_status ON medical_tests(status);

COMMENT ON TABLE medical_tests IS 'Laboratory tests, imaging, and diagnostic procedures';
COMMENT ON COLUMN medical_tests.test_type IS 'Category: Blood Test, Imaging, Diagnostic, Procedure, Immunization';

-- ================================================
-- TABLE 8: billing
-- Purpose: Financial transactions and insurance claims
-- ================================================

CREATE TABLE billing (
    billing_id SERIAL PRIMARY KEY,
    patient_id INTEGER NOT NULL,
    appointment_id INTEGER,
    admission_id INTEGER,
    bill_date DATE NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    insurance_covered DECIMAL(10, 2) NOT NULL DEFAULT 0,
    patient_responsibility DECIMAL(10, 2) NOT NULL,
    payment_status VARCHAR(20) NOT NULL DEFAULT 'Pending',
    payment_date DATE,
    payment_method VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_billing_patient FOREIGN KEY (patient_id) 
        REFERENCES patients(patient_id) ON DELETE RESTRICT,
    CONSTRAINT fk_billing_appointment FOREIGN KEY (appointment_id) 
        REFERENCES appointments(appointment_id) ON DELETE SET NULL,
    CONSTRAINT fk_billing_admission FOREIGN KEY (admission_id) 
        REFERENCES admissions(admission_id) ON DELETE SET NULL,
    CONSTRAINT chk_billing_amounts CHECK (
        total_amount > 0 AND 
        insurance_covered >= 0 AND 
        patient_responsibility >= 0 AND
        total_amount = insurance_covered + patient_responsibility
    ),
    CONSTRAINT chk_payment_status CHECK (payment_status IN ('Pending', 'Paid', 'Partially Paid', 'Cancelled', 'Refunded')),
    CONSTRAINT chk_payment_date CHECK (payment_date IS NULL OR payment_date >= bill_date),
    CONSTRAINT chk_payment_method CHECK (
        payment_method IS NULL OR 
        payment_method IN ('Cash', 'Credit Card', 'Debit Card', 'Check', 'Insurance', 'Wire Transfer')
    ),
    CONSTRAINT chk_billing_source CHECK (
        (appointment_id IS NOT NULL AND admission_id IS NULL) OR
        (appointment_id IS NULL AND admission_id IS NOT NULL)
    )
);

CREATE INDEX idx_billing_patient ON billing(patient_id);
CREATE INDEX idx_billing_appointment ON billing(appointment_id);
CREATE INDEX idx_billing_admission ON billing(admission_id);
CREATE INDEX idx_billing_date ON billing(bill_date);
CREATE INDEX idx_billing_status ON billing(payment_status);
CREATE INDEX idx_billing_payment_date ON billing(payment_date);

COMMENT ON TABLE billing IS 'Financial transactions and insurance claims';
COMMENT ON COLUMN billing.patient_responsibility IS 'Amount patient must pay after insurance';

-- ================================================
-- TABLE 9: staff
-- Purpose: Non-physician hospital personnel
-- ================================================

CREATE TABLE staff (
    staff_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    role VARCHAR(100) NOT NULL,
    department_id INTEGER,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    hire_date DATE NOT NULL,
    salary DECIMAL(10, 2) NOT NULL,
    shift VARCHAR(20) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_staff_department FOREIGN KEY (department_id) 
        REFERENCES departments(department_id) ON DELETE SET NULL,
    CONSTRAINT chk_staff_name CHECK (LENGTH(first_name) >= 2 AND LENGTH(last_name) >= 2),
    CONSTRAINT chk_staff_email CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$'),
    CONSTRAINT chk_hire_date CHECK (hire_date >= '2000-01-01' AND hire_date <= CURRENT_DATE),
    CONSTRAINT chk_salary CHECK (salary >= 0 AND salary <= 500000),
    CONSTRAINT chk_shift CHECK (shift IN ('Day', 'Evening', 'Night', 'Rotating'))
);

CREATE INDEX idx_staff_name ON staff(last_name, first_name);
CREATE INDEX idx_staff_role ON staff(role);
CREATE INDEX idx_staff_department ON staff(department_id);
CREATE INDEX idx_staff_email ON staff(email);
CREATE INDEX idx_staff_shift ON staff(shift);

COMMENT ON TABLE staff IS 'Non-physician hospital personnel (nurses, technicians, support staff)';
COMMENT ON COLUMN staff.shift IS 'Work shift: Day, Evening, Night, or Rotating';

-- ================================================
-- TABLE 10: audit_log
-- Purpose: System audit trail for compliance and debugging
-- ================================================

CREATE TABLE audit_log (
    log_id SERIAL PRIMARY KEY,
    table_name VARCHAR(50) NOT NULL,
    operation VARCHAR(10) NOT NULL,
    record_id INTEGER,
    changed_by VARCHAR(100) NOT NULL,
    changed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    old_data JSONB,
    new_data JSONB,
    
    CONSTRAINT chk_operation CHECK (operation IN ('INSERT', 'UPDATE', 'DELETE')),
    CONSTRAINT chk_table_name CHECK (LENGTH(table_name) >= 3)
);

CREATE INDEX idx_audit_table ON audit_log(table_name);
CREATE INDEX idx_audit_operation ON audit_log(operation);
CREATE INDEX idx_audit_date ON audit_log(changed_at);
CREATE INDEX idx_audit_user ON audit_log(changed_by);
CREATE INDEX idx_audit_record ON audit_log(table_name, record_id);

COMMENT ON TABLE audit_log IS 'Complete audit trail for HIPAA compliance and system debugging';
COMMENT ON COLUMN audit_log.old_data IS 'Previous values stored as JSONB (NULL for INSERT)';
COMMENT ON COLUMN audit_log.new_data IS 'New values stored as JSONB (NULL for DELETE)';

-- ================================================
-- End of Schema Definition
-- Total Tables: 10
-- Total Indexes: 50+
-- Total Constraints: 80+
-- ================================================
