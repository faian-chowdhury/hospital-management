-- ================================================
-- Hospital Management System - Views
-- Student: FAIAN
-- Option 3: Coding-Heavy DBA / DevOps Project
-- Date: October 9, 2025
-- ================================================

-- This file contains:
-- - 8 Regular Views for data access
-- - 2 Materialized Views for performance
-- Total: 10 views

-- ================================================
-- REGULAR VIEWS (8 views)
-- ================================================

-- View 1: Complete doctor information with department details
CREATE OR REPLACE VIEW v_doctor_directory AS
SELECT 
    d.doctor_id,
    d.first_name || ' ' || d.last_name AS doctor_name,
    d.specialization,
    dept.department_name,
    dept.floor_number,
    dept.phone_extension,
    d.phone AS direct_phone,
    d.email,
    d.years_of_experience,
    d.consultation_fee,
    d.is_active,
    d.license_number
FROM doctors d
INNER JOIN departments dept ON d.department_id = dept.department_id
ORDER BY dept.department_name, d.last_name;

COMMENT ON VIEW v_doctor_directory IS 'Complete directory of doctors with department information';

-- View 2: Patient summary with insurance and contact info
CREATE OR REPLACE VIEW v_patient_summary AS
SELECT 
    p.patient_id,
    p.first_name || ' ' || p.last_name AS patient_name,
    EXTRACT(YEAR FROM AGE(p.date_of_birth)) AS age,
    p.gender,
    p.blood_type,
    p.phone,
    p.email,
    p.address || ', ' || p.city || ', ' || p.state || ' ' || p.zip_code AS full_address,
    p.insurance_provider,
    p.insurance_policy_number,
    p.emergency_contact_name,
    p.emergency_contact_phone,
    p.created_at AS registration_date
FROM patients p
ORDER BY p.last_name, p.first_name;

COMMENT ON VIEW v_patient_summary IS 'Patient demographics with calculated age and formatted address';

-- View 3: Upcoming appointments
CREATE OR REPLACE VIEW v_upcoming_appointments AS
SELECT 
    a.appointment_id,
    a.appointment_date,
    a.appointment_time,
    p.first_name || ' ' || p.last_name AS patient_name,
    p.phone AS patient_phone,
    d.first_name || ' ' || d.last_name AS doctor_name,
    d.specialization,
    dept.department_name,
    dept.floor_number,
    a.reason,
    a.status
FROM appointments a
JOIN patients p ON a.patient_id = p.patient_id
JOIN doctors d ON a.doctor_id = d.doctor_id
JOIN departments dept ON d.department_id = dept.department_id
WHERE a.status = 'Scheduled'
  AND a.appointment_date >= CURRENT_DATE
ORDER BY a.appointment_date, a.appointment_time;

COMMENT ON VIEW v_upcoming_appointments IS 'All scheduled future appointments with patient and doctor details';

-- View 4: Currently admitted patients
CREATE OR REPLACE VIEW v_current_admissions AS
SELECT 
    ad.admission_id,
    p.patient_id,
    p.first_name || ' ' || p.last_name AS patient_name,
    p.date_of_birth,
    EXTRACT(YEAR FROM AGE(p.date_of_birth)) AS age,
    p.blood_type,
    ad.admission_date,
    CURRENT_DATE - ad.admission_date AS days_admitted,
    ad.room_number,
    ad.bed_number,
    ad.admission_type,
    ad.primary_diagnosis,
    d.first_name || ' ' || d.last_name AS attending_doctor,
    d.specialization,
    dept.department_name
FROM admissions ad
JOIN patients p ON ad.patient_id = p.patient_id
JOIN doctors d ON ad.attending_doctor_id = d.doctor_id
JOIN departments dept ON d.department_id = dept.department_id
WHERE ad.discharge_date IS NULL
ORDER BY ad.admission_date, ad.room_number;

COMMENT ON VIEW v_current_admissions IS 'All currently admitted patients with length of stay calculation';

-- View 5: Active prescriptions
CREATE OR REPLACE VIEW v_active_prescriptions AS
SELECT 
    pr.prescription_id,
    p.patient_id,
    p.first_name || ' ' || p.last_name AS patient_name,
    p.phone AS patient_phone,
    d.first_name || ' ' || d.last_name AS prescribing_doctor,
    pr.medication_name,
    pr.dosage,
    pr.frequency,
    pr.start_date,
    pr.end_date,
    pr.end_date - CURRENT_DATE AS days_remaining,
    pr.refills_allowed,
    pr.instructions
FROM prescriptions pr
JOIN patients p ON pr.patient_id = p.patient_id
JOIN doctors d ON pr.doctor_id = d.doctor_id
WHERE pr.end_date >= CURRENT_DATE
ORDER BY pr.end_date, p.last_name;

COMMENT ON VIEW v_active_prescriptions IS 'Currently active prescriptions with days remaining';

-- View 6: Pending medical tests
CREATE OR REPLACE VIEW v_pending_tests AS
SELECT 
    mt.test_id,
    mt.test_type,
    mt.test_name,
    mt.test_date,
    mt.status,
    p.patient_id,
    p.first_name || ' ' || p.last_name AS patient_name,
    p.phone AS patient_phone,
    d.first_name || ' ' || d.last_name AS ordering_doctor,
    d.phone AS doctor_phone,
    dept.department_name,
    mt.notes
FROM medical_tests mt
JOIN patients p ON mt.patient_id = p.patient_id
JOIN doctors d ON mt.doctor_id = d.doctor_id
JOIN departments dept ON d.department_id = dept.department_id
WHERE mt.status IN ('Pending', 'Scheduled', 'In Progress')
ORDER BY mt.test_date, mt.test_type;

COMMENT ON VIEW v_pending_tests IS 'All tests that are not yet completed';

-- View 7: Outstanding billing
CREATE OR REPLACE VIEW v_outstanding_billing AS
SELECT 
    b.billing_id,
    p.patient_id,
    p.first_name || ' ' || p.last_name AS patient_name,
    p.phone AS patient_phone,
    p.email AS patient_email,
    p.insurance_provider,
    b.bill_date,
    CURRENT_DATE - b.bill_date AS days_outstanding,
    b.total_amount,
    b.insurance_covered,
    b.patient_responsibility,
    b.payment_status,
    CASE 
        WHEN b.payment_status = 'Pending' THEN b.patient_responsibility
        ELSE 0
    END AS amount_due
FROM billing b
JOIN patients p ON b.patient_id = p.patient_id
WHERE b.payment_status IN ('Pending', 'Partially Paid')
ORDER BY b.bill_date, b.patient_responsibility DESC;

COMMENT ON VIEW v_outstanding_billing IS 'All unpaid or partially paid bills';

-- View 8: Department staff roster
CREATE OR REPLACE VIEW v_department_staff AS
SELECT 
    dept.department_id,
    dept.department_name,
    dept.floor_number,
    dept.phone_extension,
    dept.department_head,
    -- Doctors
    COUNT(DISTINCT d.doctor_id) AS total_doctors,
    COUNT(DISTINCT CASE WHEN d.is_active THEN d.doctor_id END) AS active_doctors,
    STRING_AGG(DISTINCT CASE WHEN d.is_active THEN d.first_name || ' ' || d.last_name END, ', ' ORDER BY d.last_name) AS doctor_names,
    -- Support Staff
    COUNT(DISTINCT s.staff_id) AS total_staff,
    COUNT(DISTINCT CASE WHEN s.is_active THEN s.staff_id END) AS active_staff,
    STRING_AGG(DISTINCT CASE WHEN s.is_active THEN s.first_name || ' ' || s.last_name || ' (' || s.role || ')' END, ', ' ORDER BY s.last_name) AS staff_names
FROM departments dept
LEFT JOIN doctors d ON dept.department_id = d.department_id
LEFT JOIN staff s ON dept.department_id = s.department_id
GROUP BY dept.department_id, dept.department_name, dept.floor_number, dept.phone_extension, dept.department_head
ORDER BY dept.department_name;

COMMENT ON VIEW v_department_staff IS 'Complete roster of doctors and staff by department';

-- ================================================
-- MATERIALIZED VIEWS (2 views)
-- ================================================

-- Materialized View 1: Doctor performance metrics
CREATE MATERIALIZED VIEW mv_doctor_performance AS
SELECT 
    d.doctor_id,
    d.first_name || ' ' || d.last_name AS doctor_name,
    d.specialization,
    dept.department_name,
    -- Appointment metrics
    COUNT(DISTINCT a.appointment_id) AS total_appointments,
    COUNT(DISTINCT CASE WHEN a.status = 'Completed' THEN a.appointment_id END) AS completed_appointments,
    COUNT(DISTINCT CASE WHEN a.status = 'Cancelled' THEN a.appointment_id END) AS cancelled_appointments,
    COUNT(DISTINCT CASE WHEN a.status = 'No-Show' THEN a.appointment_id END) AS no_show_appointments,
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN a.status = 'Completed' THEN a.appointment_id END) / 
          NULLIF(COUNT(DISTINCT a.appointment_id), 0), 2) AS completion_rate,
    -- Patient metrics
    COUNT(DISTINCT a.patient_id) AS unique_patients,
    -- Prescription metrics
    COUNT(DISTINCT pr.prescription_id) AS prescriptions_written,
    -- Test metrics
    COUNT(DISTINCT mt.test_id) AS tests_ordered,
    -- Admission metrics
    COUNT(DISTINCT ad.admission_id) AS admissions_handled,
    -- Financial metrics
    COALESCE(SUM(b.total_amount), 0) AS total_revenue_generated,
    ROUND(COALESCE(AVG(b.total_amount), 0), 2) AS avg_revenue_per_visit,
    -- Ratings (placeholder for future enhancement)
    d.years_of_experience,
    d.consultation_fee
FROM doctors d
JOIN departments dept ON d.department_id = dept.department_id
LEFT JOIN appointments a ON d.doctor_id = a.doctor_id
LEFT JOIN prescriptions pr ON d.doctor_id = pr.doctor_id
LEFT JOIN medical_tests mt ON d.doctor_id = mt.doctor_id
LEFT JOIN admissions ad ON d.doctor_id = ad.attending_doctor_id
LEFT JOIN billing b ON a.appointment_id = b.appointment_id
WHERE d.is_active = TRUE
GROUP BY 
    d.doctor_id, 
    d.first_name, 
    d.last_name, 
    d.specialization, 
    dept.department_name,
    d.years_of_experience,
    d.consultation_fee
ORDER BY total_revenue_generated DESC;

-- Create unique index for concurrent refresh
CREATE UNIQUE INDEX idx_mv_doctor_performance_id ON mv_doctor_performance(doctor_id);

COMMENT ON MATERIALIZED VIEW mv_doctor_performance IS 'Comprehensive doctor performance analytics - refresh daily';

-- Materialized View 2: Department analytics
CREATE MATERIALIZED VIEW mv_department_analytics AS
SELECT 
    dept.department_id,
    dept.department_name,
    dept.floor_number,
    dept.phone_extension,
    -- Staffing metrics
    COUNT(DISTINCT d.doctor_id) AS total_doctors,
    COUNT(DISTINCT CASE WHEN d.is_active THEN d.doctor_id END) AS active_doctors,
    COUNT(DISTINCT s.staff_id) AS total_support_staff,
    COUNT(DISTINCT CASE WHEN s.is_active THEN s.staff_id END) AS active_support_staff,
    ROUND(AVG(d.years_of_experience), 1) AS avg_doctor_experience,
    ROUND(AVG(d.consultation_fee), 2) AS avg_consultation_fee,
    -- Activity metrics
    COUNT(DISTINCT a.appointment_id) AS total_appointments,
    COUNT(DISTINCT CASE WHEN a.status = 'Completed' THEN a.appointment_id END) AS completed_appointments,
    COUNT(DISTINCT ad.admission_id) AS total_admissions,
    COUNT(DISTINCT CASE WHEN ad.discharge_date IS NULL THEN ad.admission_id END) AS current_admissions,
    -- Patient metrics
    COUNT(DISTINCT a.patient_id) AS unique_patients_seen,
    -- Financial metrics
    COALESCE(SUM(b.total_amount), 0) AS total_department_revenue,
    ROUND(COALESCE(AVG(b.total_amount), 0), 2) AS avg_bill_amount,
    -- Utilization metrics
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN a.status = 'Completed' THEN a.appointment_id END) / 
          NULLIF(COUNT(DISTINCT a.appointment_id), 0), 2) AS appointment_completion_rate,
    -- Average length of stay for admissions
    ROUND(AVG(
        CASE 
            WHEN ad.discharge_date IS NOT NULL 
            THEN ad.discharge_date - ad.admission_date 
            ELSE NULL 
        END
    ), 1) AS avg_length_of_stay_days
FROM departments dept
LEFT JOIN doctors d ON dept.department_id = d.department_id
LEFT JOIN staff s ON dept.department_id = s.department_id
LEFT JOIN appointments a ON d.doctor_id = a.doctor_id
LEFT JOIN admissions ad ON d.doctor_id = ad.attending_doctor_id
LEFT JOIN billing b ON (a.appointment_id = b.appointment_id OR ad.admission_id = b.admission_id)
GROUP BY 
    dept.department_id, 
    dept.department_name, 
    dept.floor_number,
    dept.phone_extension
ORDER BY total_department_revenue DESC;

-- Create unique index for concurrent refresh
CREATE UNIQUE INDEX idx_mv_department_analytics_id ON mv_department_analytics(department_id);

COMMENT ON MATERIALIZED VIEW mv_department_analytics IS 'Department-level performance and utilization metrics - refresh daily';

-- ================================================
-- View Usage Examples
-- ================================================

-- Example 1: Query upcoming appointments
-- SELECT * FROM v_upcoming_appointments WHERE appointment_date = CURRENT_DATE;

-- Example 2: Check current admissions
-- SELECT * FROM v_current_admissions WHERE days_admitted > 7;

-- Example 3: Find outstanding billing
-- SELECT * FROM v_outstanding_billing WHERE days_outstanding > 30;

-- Example 4: View doctor performance
-- SELECT * FROM mv_doctor_performance WHERE completion_rate > 90;

-- Example 5: Department comparison
-- SELECT * FROM mv_department_analytics ORDER BY total_department_revenue DESC;

-- Example 6: Refresh materialized views (run daily)
-- REFRESH MATERIALIZED VIEW CONCURRENTLY mv_doctor_performance;
-- REFRESH MATERIALIZED VIEW CONCURRENTLY mv_department_analytics;
-- Or use: SELECT refresh_all_materialized_views();

-- ================================================
-- End of Views
-- Regular Views: 8
-- Materialized Views: 2
-- Total: 10 views
-- ================================================
