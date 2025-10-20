-- ================================================
-- Hospital Management System - Roles & Security
-- Student: FAIAN
-- Option 3: Coding-Heavy DBA / DevOps Project
-- Date: October 9, 2025
-- ================================================

-- This file contains:
-- - 5 User Roles with appropriate permissions
-- - 25 Row-Level Security (RLS) Policies
-- - HIPAA-compliant data access controls

-- ================================================
-- SECTION 1: CREATE ROLES
-- ================================================

-- Role 1: Administrator (Full Access)
CREATE ROLE hospital_admin;
COMMENT ON ROLE hospital_admin IS 'Hospital administrators with full system access';

-- Role 2: Doctor (Medical Staff)
CREATE ROLE hospital_doctor;
COMMENT ON ROLE hospital_doctor IS 'Medical doctors with patient care access';

-- Role 3: Nurse/Staff (Support Staff)
CREATE ROLE hospital_staff;
COMMENT ON ROLE hospital_staff IS 'Nurses and support staff with limited access';

-- Role 4: Patient (Self-Service Portal)
CREATE ROLE hospital_patient;
COMMENT ON ROLE hospital_patient IS 'Patients accessing their own records';

-- Role 5: Billing Department
CREATE ROLE hospital_billing;
COMMENT ON ROLE hospital_billing IS 'Billing staff with financial data access';

-- ================================================
-- SECTION 2: GRANT TABLE PERMISSIONS
-- ================================================

-- Administrator: Full access to all tables
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO hospital_admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO hospital_admin;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO hospital_admin;

-- Doctor: Read/Write on clinical tables
GRANT SELECT, INSERT, UPDATE ON patients, appointments, prescriptions, medical_tests, admissions TO hospital_doctor;
GRANT SELECT ON departments, doctors, staff TO hospital_doctor;
GRANT SELECT ON billing TO hospital_doctor; -- Read-only for billing
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO hospital_doctor;

-- Staff: Read/Write on operational tables
GRANT SELECT, INSERT, UPDATE ON appointments, medical_tests TO hospital_staff;
GRANT SELECT ON patients, doctors, departments, admissions, prescriptions TO hospital_staff;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO hospital_staff;

-- Patient: Read-only on their own data
GRANT SELECT ON patients, appointments, prescriptions, medical_tests, billing, admissions TO hospital_patient;

-- Billing: Full access to billing, read-only on clinical
GRANT SELECT, INSERT, UPDATE, DELETE ON billing TO hospital_billing;
GRANT SELECT ON patients, appointments, admissions, doctors, departments TO hospital_billing;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO hospital_billing;

-- ================================================
-- SECTION 3: ENABLE ROW LEVEL SECURITY
-- ================================================

ALTER TABLE patients ENABLE ROW LEVEL SECURITY;
ALTER TABLE appointments ENABLE ROW LEVEL SECURITY;
ALTER TABLE prescriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE medical_tests ENABLE ROW LEVEL SECURITY;
ALTER TABLE admissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE billing ENABLE ROW LEVEL SECURITY;

COMMENT ON TABLE patients IS 'RLS enabled - patients see only their own data';

-- ================================================
-- SECTION 4: ROW LEVEL SECURITY POLICIES
-- ================================================

-- ============================================
-- POLICIES FOR PATIENTS TABLE (5 policies)
-- ============================================

-- Policy 1: Patients can view their own record
CREATE POLICY patient_view_own_record ON patients
    FOR SELECT
    TO hospital_patient
    USING (patient_id = current_setting('app.current_patient_id', TRUE)::INTEGER);

-- Policy 2: Doctors can view all patients
CREATE POLICY doctor_view_all_patients ON patients
    FOR SELECT
    TO hospital_doctor
    USING (true);

-- Policy 3: Staff can view all patients
CREATE POLICY staff_view_all_patients ON patients
    FOR SELECT
    TO hospital_staff
    USING (true);

-- Policy 4: Doctors can update patient records
CREATE POLICY doctor_update_patients ON patients
    FOR UPDATE
    TO hospital_doctor
    USING (true)
    WITH CHECK (true);

-- Policy 5: Admins have full access
CREATE POLICY admin_all_patients ON patients
    FOR ALL
    TO hospital_admin
    USING (true)
    WITH CHECK (true);

-- ============================================
-- POLICIES FOR APPOINTMENTS TABLE (5 policies)
-- ============================================

-- Policy 6: Patients view their own appointments
CREATE POLICY patient_view_own_appointments ON appointments
    FOR SELECT
    TO hospital_patient
    USING (patient_id = current_setting('app.current_patient_id', TRUE)::INTEGER);

-- Policy 7: Doctors view their appointments
CREATE POLICY doctor_view_own_appointments ON appointments
    FOR SELECT
    TO hospital_doctor
    USING (doctor_id = current_setting('app.current_doctor_id', TRUE)::INTEGER);

-- Policy 8: Doctors manage their appointments
CREATE POLICY doctor_manage_appointments ON appointments
    FOR ALL
    TO hospital_doctor
    USING (doctor_id = current_setting('app.current_doctor_id', TRUE)::INTEGER)
    WITH CHECK (doctor_id = current_setting('app.current_doctor_id', TRUE)::INTEGER);

-- Policy 9: Staff view all appointments
CREATE POLICY staff_view_appointments ON appointments
    FOR SELECT
    TO hospital_staff
    USING (true);

-- Policy 10: Admins have full access
CREATE POLICY admin_all_appointments ON appointments
    FOR ALL
    TO hospital_admin
    USING (true)
    WITH CHECK (true);

-- ============================================
-- POLICIES FOR PRESCRIPTIONS TABLE (5 policies)
-- ============================================

-- Policy 11: Patients view their own prescriptions
CREATE POLICY patient_view_own_prescriptions ON prescriptions
    FOR SELECT
    TO hospital_patient
    USING (patient_id = current_setting('app.current_patient_id', TRUE)::INTEGER);

-- Policy 12: Doctors view prescriptions they wrote
CREATE POLICY doctor_view_own_prescriptions ON prescriptions
    FOR SELECT
    TO hospital_doctor
    USING (doctor_id = current_setting('app.current_doctor_id', TRUE)::INTEGER);

-- Policy 13: Doctors create and update their prescriptions
CREATE POLICY doctor_manage_prescriptions ON prescriptions
    FOR ALL
    TO hospital_doctor
    USING (doctor_id = current_setting('app.current_doctor_id', TRUE)::INTEGER)
    WITH CHECK (doctor_id = current_setting('app.current_doctor_id', TRUE)::INTEGER);

-- Policy 14: Staff view prescriptions (pharmacy)
CREATE POLICY staff_view_prescriptions ON prescriptions
    FOR SELECT
    TO hospital_staff
    USING (true);

-- Policy 15: Admins have full access
CREATE POLICY admin_all_prescriptions ON prescriptions
    FOR ALL
    TO hospital_admin
    USING (true)
    WITH CHECK (true);

-- ============================================
-- POLICIES FOR MEDICAL_TESTS TABLE (5 policies)
-- ============================================

-- Policy 16: Patients view their own test results
CREATE POLICY patient_view_own_tests ON medical_tests
    FOR SELECT
    TO hospital_patient
    USING (patient_id = current_setting('app.current_patient_id', TRUE)::INTEGER);

-- Policy 17: Doctors view tests they ordered
CREATE POLICY doctor_view_ordered_tests ON medical_tests
    FOR SELECT
    TO hospital_doctor
    USING (doctor_id = current_setting('app.current_doctor_id', TRUE)::INTEGER);

-- Policy 18: Doctors manage their test orders
CREATE POLICY doctor_manage_tests ON medical_tests
    FOR ALL
    TO hospital_doctor
    USING (doctor_id = current_setting('app.current_doctor_id', TRUE)::INTEGER)
    WITH CHECK (doctor_id = current_setting('app.current_doctor_id', TRUE)::INTEGER);

-- Policy 19: Staff update test results
CREATE POLICY staff_update_tests ON medical_tests
    FOR UPDATE
    TO hospital_staff
    USING (true)
    WITH CHECK (true);

-- Policy 20: Admins have full access
CREATE POLICY admin_all_tests ON medical_tests
    FOR ALL
    TO hospital_admin
    USING (true)
    WITH CHECK (true);

-- ============================================
-- POLICIES FOR BILLING TABLE (5 policies)
-- ============================================

-- Policy 21: Patients view their own bills
CREATE POLICY patient_view_own_billing ON billing
    FOR SELECT
    TO hospital_patient
    USING (patient_id = current_setting('app.current_patient_id', TRUE)::INTEGER);

-- Policy 22: Billing staff full access to all bills
CREATE POLICY billing_manage_all_bills ON billing
    FOR ALL
    TO hospital_billing
    USING (true)
    WITH CHECK (true);

-- Policy 23: Doctors view bills for their patients
CREATE POLICY doctor_view_patient_billing ON billing
    FOR SELECT
    TO hospital_doctor
    USING (
        EXISTS (
            SELECT 1 FROM appointments a 
            WHERE a.appointment_id = billing.appointment_id 
            AND a.doctor_id = current_setting('app.current_doctor_id', TRUE)::INTEGER
        )
        OR EXISTS (
            SELECT 1 FROM admissions ad
            WHERE ad.admission_id = billing.admission_id
            AND ad.attending_doctor_id = current_setting('app.current_doctor_id', TRUE)::INTEGER
        )
    );

-- Policy 24: Staff view billing (limited)
CREATE POLICY staff_view_billing ON billing
    FOR SELECT
    TO hospital_staff
    USING (payment_status != 'Cancelled');

-- Policy 25: Admins have full access
CREATE POLICY admin_all_billing ON billing
    FOR ALL
    TO hospital_admin
    USING (true)
    WITH CHECK (true);

-- ================================================
-- SECTION 5: ADDITIONAL SECURITY MEASURES
-- ================================================

-- Revoke public access to sensitive tables
REVOKE ALL ON patients, appointments, prescriptions, medical_tests, billing, admissions FROM PUBLIC;

-- Create function to set user context (for application use)
CREATE OR REPLACE FUNCTION set_user_context(user_role TEXT, user_id INTEGER)
RETURNS void AS $$
BEGIN
    CASE user_role
        WHEN 'patient' THEN
            PERFORM set_config('app.current_patient_id', user_id::TEXT, FALSE);
        WHEN 'doctor' THEN
            PERFORM set_config('app.current_doctor_id', user_id::TEXT, FALSE);
        WHEN 'staff' THEN
            PERFORM set_config('app.current_staff_id', user_id::TEXT, FALSE);
        WHEN 'billing' THEN
            PERFORM set_config('app.current_billing_user', user_id::TEXT, FALSE);
        ELSE
            RAISE EXCEPTION 'Invalid user role: %', user_role;
    END CASE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION set_user_context IS 'Sets user context for RLS policies';

-- Create function to mask sensitive data
CREATE OR REPLACE FUNCTION mask_ssn(ssn TEXT)
RETURNS TEXT AS $$
BEGIN
    IF ssn IS NULL THEN
        RETURN NULL;
    END IF;
    RETURN 'XXX-XX-' || RIGHT(ssn, 4);
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION mask_ssn IS 'Masks SSN for HIPAA compliance (shows only last 4 digits)';

-- Create function to mask credit card
CREATE OR REPLACE FUNCTION mask_credit_card(card_number TEXT)
RETURNS TEXT AS $$
BEGIN
    IF card_number IS NULL THEN
        RETURN NULL;
    END IF;
    RETURN '**** **** **** ' || RIGHT(card_number, 4);
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION mask_credit_card IS 'Masks credit card number for PCI compliance';

-- ================================================
-- SECTION 6: AUDIT AND COMPLIANCE
-- ================================================

-- Grant audit log access to admins and compliance officers
GRANT SELECT ON audit_log TO hospital_admin;
GRANT SELECT ON audit_log TO hospital_billing; -- For financial audits

-- Create view for compliance reporting
CREATE OR REPLACE VIEW v_hipaa_audit_trail AS
SELECT 
    log_id,
    table_name,
    operation,
    changed_by,
    changed_at,
    CASE 
        WHEN table_name IN ('patients', 'prescriptions', 'medical_tests', 'admissions') 
        THEN 'Protected Health Information (PHI)'
        WHEN table_name = 'billing'
        THEN 'Financial Data'
        ELSE 'Administrative Data'
    END AS data_classification,
    old_data,
    new_data
FROM audit_log
WHERE changed_at >= CURRENT_DATE - INTERVAL '90 days'
ORDER BY changed_at DESC;

GRANT SELECT ON v_hipaa_audit_trail TO hospital_admin;

COMMENT ON VIEW v_hipaa_audit_trail IS 'HIPAA-compliant audit trail for last 90 days';

-- ================================================
-- SECTION 7: USAGE EXAMPLES
-- ================================================

-- Example 1: Set patient context
-- SELECT set_user_context('patient', 1);
-- SELECT * FROM patients; -- Will see only patient_id = 1

-- Example 2: Set doctor context
-- SELECT set_user_context('doctor', 2);
-- SELECT * FROM appointments; -- Will see only appointments for doctor_id = 2

-- Example 3: Create a new user and assign role
-- CREATE USER dr_smith WITH PASSWORD 'secure_password';
-- GRANT hospital_doctor TO dr_smith;

-- Example 4: Create a patient portal user
-- CREATE USER patient_john WITH PASSWORD 'patient_password';
-- GRANT hospital_patient TO patient_john;

-- Example 5: View audit trail (admin only)
-- SET ROLE hospital_admin;
-- SELECT * FROM v_hipaa_audit_trail WHERE data_classification = 'Protected Health Information (PHI)';

-- ================================================
-- End of Roles & Security
-- Roles: 5 (Admin, Doctor, Staff, Patient, Billing)
-- RLS Policies: 25
-- Security Functions: 3
-- Compliance: HIPAA and PCI DSS compliant structure
-- ================================================
