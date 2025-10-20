-- ================================================
-- Hospital Management System - Triggers
-- Student: FAIAN
-- Option 3: Coding-Heavy DBA / DevOps Project
-- Date: October 9, 2025
-- ================================================

-- This file contains 7 triggers and 4 utility functions for:
-- - Automatic timestamp updates
-- - Billing calculations
-- - Appointment validation
-- - Admission status tracking
-- - Test result notifications
-- - Audit logging
-- - Data integrity enforcement

-- ================================================
-- UTILITY FUNCTIONS
-- ================================================

-- Function 1: Update timestamp on any table
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION update_updated_at_column() IS 'Automatically updates the updated_at timestamp';

-- Function 2: Calculate billing patient responsibility
CREATE OR REPLACE FUNCTION calculate_patient_responsibility()
RETURNS TRIGGER AS $$
BEGIN
    -- Automatically calculate patient responsibility
    NEW.patient_responsibility = NEW.total_amount - NEW.insurance_covered;
    
    -- Ensure non-negative values
    IF NEW.patient_responsibility < 0 THEN
        NEW.patient_responsibility = 0;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION calculate_patient_responsibility() IS 'Calculates patient responsibility based on total and insurance coverage';

-- Function 3: Log changes to audit_log
CREATE OR REPLACE FUNCTION log_audit_trail()
RETURNS TRIGGER AS $$
DECLARE
    v_user TEXT;
BEGIN
    -- Get current user (or use system if not available)
    v_user := COALESCE(current_setting('app.current_user', TRUE), 'system');
    
    IF TG_OP = 'INSERT' THEN
        INSERT INTO audit_log (table_name, operation, record_id, changed_by, old_data, new_data)
        VALUES (
            TG_TABLE_NAME,
            'INSERT',
            CASE 
                WHEN TG_TABLE_NAME = 'patients' THEN NEW.patient_id
                WHEN TG_TABLE_NAME = 'doctors' THEN NEW.doctor_id
                WHEN TG_TABLE_NAME = 'appointments' THEN NEW.appointment_id
                WHEN TG_TABLE_NAME = 'admissions' THEN NEW.admission_id
                WHEN TG_TABLE_NAME = 'prescriptions' THEN NEW.prescription_id
                WHEN TG_TABLE_NAME = 'billing' THEN NEW.billing_id
                ELSE NULL
            END,
            v_user,
            NULL,
            row_to_json(NEW)
        );
        RETURN NEW;
        
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO audit_log (table_name, operation, record_id, changed_by, old_data, new_data)
        VALUES (
            TG_TABLE_NAME,
            'UPDATE',
            CASE 
                WHEN TG_TABLE_NAME = 'patients' THEN NEW.patient_id
                WHEN TG_TABLE_NAME = 'doctors' THEN NEW.doctor_id
                WHEN TG_TABLE_NAME = 'appointments' THEN NEW.appointment_id
                WHEN TG_TABLE_NAME = 'admissions' THEN NEW.admission_id
                WHEN TG_TABLE_NAME = 'prescriptions' THEN NEW.prescription_id
                WHEN TG_TABLE_NAME = 'billing' THEN NEW.billing_id
                ELSE NULL
            END,
            v_user,
            row_to_json(OLD),
            row_to_json(NEW)
        );
        RETURN NEW;
        
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO audit_log (table_name, operation, record_id, changed_by, old_data, new_data)
        VALUES (
            TG_TABLE_NAME,
            'DELETE',
            CASE 
                WHEN TG_TABLE_NAME = 'patients' THEN OLD.patient_id
                WHEN TG_TABLE_NAME = 'doctors' THEN OLD.doctor_id
                WHEN TG_TABLE_NAME = 'appointments' THEN OLD.appointment_id
                WHEN TG_TABLE_NAME = 'admissions' THEN OLD.admission_id
                WHEN TG_TABLE_NAME = 'prescriptions' THEN OLD.prescription_id
                WHEN TG_TABLE_NAME = 'billing' THEN OLD.billing_id
                ELSE NULL
            END,
            v_user,
            row_to_json(OLD),
            NULL
        );
        RETURN OLD;
    END IF;
    
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION log_audit_trail() IS 'Comprehensive audit logging for HIPAA compliance';

-- Function 4: Validate appointment scheduling
CREATE OR REPLACE FUNCTION validate_appointment()
RETURNS TRIGGER AS $$
DECLARE
    v_doctor_active BOOLEAN;
    v_conflicting_appointments INTEGER;
BEGIN
    -- Check if doctor is active
    SELECT is_active INTO v_doctor_active
    FROM doctors
    WHERE doctor_id = NEW.doctor_id;
    
    IF NOT v_doctor_active THEN
        RAISE EXCEPTION 'Cannot schedule appointment with inactive doctor (ID: %)', NEW.doctor_id;
    END IF;
    
    -- Check for conflicting appointments (same doctor, same date/time)
    SELECT COUNT(*) INTO v_conflicting_appointments
    FROM appointments
    WHERE doctor_id = NEW.doctor_id
      AND appointment_date = NEW.appointment_date
      AND appointment_time = NEW.appointment_time
      AND status NOT IN ('Cancelled', 'No-Show')
      AND appointment_id != COALESCE(NEW.appointment_id, -1);
    
    IF v_conflicting_appointments > 0 THEN
        RAISE EXCEPTION 'Doctor already has an appointment at this time';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION validate_appointment() IS 'Validates appointment scheduling to prevent conflicts';

-- ================================================
-- TRIGGER 1: Update timestamps on all tables
-- ================================================

CREATE TRIGGER update_departments_timestamp
    BEFORE UPDATE ON departments
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_doctors_timestamp
    BEFORE UPDATE ON doctors
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_patients_timestamp
    BEFORE UPDATE ON patients
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_appointments_timestamp
    BEFORE UPDATE ON appointments
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_admissions_timestamp
    BEFORE UPDATE ON admissions
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_prescriptions_timestamp
    BEFORE UPDATE ON prescriptions
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_medical_tests_timestamp
    BEFORE UPDATE ON medical_tests
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_billing_timestamp
    BEFORE UPDATE ON billing
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_staff_timestamp
    BEFORE UPDATE ON staff
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TRIGGER update_appointments_timestamp ON appointments IS 'Auto-updates timestamp on appointment changes';

-- ================================================
-- TRIGGER 2: Automatic billing calculation
-- ================================================

CREATE TRIGGER calculate_billing_patient_amount
    BEFORE INSERT OR UPDATE ON billing
    FOR EACH ROW
    EXECUTE FUNCTION calculate_patient_responsibility();

COMMENT ON TRIGGER calculate_billing_patient_amount ON billing IS 'Automatically calculates patient responsibility';

-- ================================================
-- TRIGGER 3: Validate appointment scheduling
-- ================================================

CREATE TRIGGER validate_appointment_before_insert
    BEFORE INSERT ON appointments
    FOR EACH ROW
    EXECUTE FUNCTION validate_appointment();

CREATE TRIGGER validate_appointment_before_update
    BEFORE UPDATE ON appointments
    FOR EACH ROW
    WHEN (OLD.doctor_id IS DISTINCT FROM NEW.doctor_id 
       OR OLD.appointment_date IS DISTINCT FROM NEW.appointment_date
       OR OLD.appointment_time IS DISTINCT FROM NEW.appointment_time)
    EXECUTE FUNCTION validate_appointment();

COMMENT ON TRIGGER validate_appointment_before_insert ON appointments IS 'Prevents scheduling conflicts';

-- ================================================
-- TRIGGER 4: Audit logging for critical tables
-- ================================================

CREATE TRIGGER audit_patients
    AFTER INSERT OR UPDATE OR DELETE ON patients
    FOR EACH ROW
    EXECUTE FUNCTION log_audit_trail();

CREATE TRIGGER audit_doctors
    AFTER INSERT OR UPDATE OR DELETE ON doctors
    FOR EACH ROW
    EXECUTE FUNCTION log_audit_trail();

CREATE TRIGGER audit_appointments
    AFTER INSERT OR UPDATE OR DELETE ON appointments
    FOR EACH ROW
    EXECUTE FUNCTION log_audit_trail();

CREATE TRIGGER audit_admissions
    AFTER INSERT OR UPDATE OR DELETE ON admissions
    FOR EACH ROW
    EXECUTE FUNCTION log_audit_trail();

CREATE TRIGGER audit_prescriptions
    AFTER INSERT OR UPDATE OR DELETE ON prescriptions
    FOR EACH ROW
    EXECUTE FUNCTION log_audit_trail();

CREATE TRIGGER audit_billing
    AFTER INSERT OR UPDATE OR DELETE ON billing
    FOR EACH ROW
    EXECUTE FUNCTION log_audit_trail();

COMMENT ON TRIGGER audit_patients ON patients IS 'HIPAA-compliant audit trail for patient data';

-- ================================================
-- TRIGGER 5: Admission discharge validation
-- ================================================

CREATE OR REPLACE FUNCTION validate_admission_discharge()
RETURNS TRIGGER AS $$
BEGIN
    -- When setting discharge date, ensure discharge status is set
    IF NEW.discharge_date IS NOT NULL AND NEW.discharge_status IS NULL THEN
        RAISE EXCEPTION 'Discharge status must be set when discharge date is provided';
    END IF;
    
    -- When removing discharge date, clear discharge status
    IF NEW.discharge_date IS NULL AND OLD.discharge_date IS NOT NULL THEN
        NEW.discharge_status = NULL;
    END IF;
    
    -- Ensure discharge date is not before admission date
    IF NEW.discharge_date IS NOT NULL AND NEW.discharge_date < NEW.admission_date THEN
        RAISE EXCEPTION 'Discharge date cannot be before admission date';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER validate_discharge_before_update
    BEFORE UPDATE ON admissions
    FOR EACH ROW
    WHEN (OLD.discharge_date IS DISTINCT FROM NEW.discharge_date 
       OR OLD.discharge_status IS DISTINCT FROM NEW.discharge_status)
    EXECUTE FUNCTION validate_admission_discharge();

COMMENT ON TRIGGER validate_discharge_before_update ON admissions IS 'Ensures proper discharge workflow';

-- ================================================
-- TRIGGER 6: Prescription end date auto-calculation
-- ================================================

CREATE OR REPLACE FUNCTION calculate_prescription_end_date()
RETURNS TRIGGER AS $$
BEGIN
    -- Auto-calculate end date if not provided
    IF NEW.end_date IS NULL AND NEW.duration_days > 0 THEN
        NEW.end_date = NEW.start_date + (NEW.duration_days || ' days')::INTERVAL;
    END IF;
    
    -- Ensure end date matches duration
    IF NEW.duration_days > 0 AND NEW.end_date != NEW.start_date + (NEW.duration_days || ' days')::INTERVAL THEN
        NEW.end_date = NEW.start_date + (NEW.duration_days || ' days')::INTERVAL;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER auto_calculate_prescription_dates
    BEFORE INSERT OR UPDATE ON prescriptions
    FOR EACH ROW
    EXECUTE FUNCTION calculate_prescription_end_date();

COMMENT ON TRIGGER auto_calculate_prescription_dates ON prescriptions IS 'Automatically calculates prescription end dates';

-- ================================================
-- TRIGGER 7: Payment date validation
-- ================================================

CREATE OR REPLACE FUNCTION validate_payment()
RETURNS TRIGGER AS $$
BEGIN
    -- If marking as paid, ensure payment date is set
    IF NEW.payment_status = 'Paid' AND NEW.payment_date IS NULL THEN
        NEW.payment_date = CURRENT_DATE;
    END IF;
    
    -- If setting payment date, ensure payment method is set
    IF NEW.payment_date IS NOT NULL AND NEW.payment_method IS NULL THEN
        RAISE EXCEPTION 'Payment method must be specified when payment date is set';
    END IF;
    
    -- Clear payment details if status changes to Pending
    IF NEW.payment_status = 'Pending' AND OLD.payment_status != 'Pending' THEN
        NEW.payment_date = NULL;
        NEW.payment_method = NULL;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER validate_payment_before_update
    BEFORE UPDATE ON billing
    FOR EACH ROW
    WHEN (OLD.payment_status IS DISTINCT FROM NEW.payment_status 
       OR OLD.payment_date IS DISTINCT FROM NEW.payment_date
       OR OLD.payment_method IS DISTINCT FROM NEW.payment_method)
    EXECUTE FUNCTION validate_payment();

COMMENT ON TRIGGER validate_payment_before_update ON billing IS 'Validates payment information consistency';

-- ================================================
-- Additional Helper Function: Refresh Materialized Views
-- ================================================

CREATE OR REPLACE FUNCTION refresh_all_materialized_views()
RETURNS void AS $$
BEGIN
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_doctor_performance;
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_department_analytics;
    RAISE NOTICE 'All materialized views refreshed successfully';
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION refresh_all_materialized_views() IS 'Refreshes all materialized views in the database';

-- ================================================
-- End of Triggers
-- Total Triggers: 7 major trigger types (multiple instances)
-- - Timestamp updates (9 triggers)
-- - Billing calculations (1 trigger)
-- - Appointment validation (2 triggers)
-- - Audit logging (6 triggers)
-- - Admission validation (1 trigger)
-- - Prescription dates (1 trigger)
-- - Payment validation (1 trigger)
-- Total Functions: 8 functions
-- ================================================
