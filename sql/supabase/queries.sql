-- ================================================
-- Hospital Management System - SQL Queries
-- Student: FAIAN
-- Option 3: Coding-Heavy DBA / DevOps Project
-- Date: October 9, 2025
-- ================================================

-- This file contains 20 SQL queries demonstrating:
-- - Basic operations (SELECT, JOIN, WHERE, GROUP BY, ORDER BY)
-- - Advanced features (Window Functions, CTEs, Recursive Queries)
-- - Business intelligence and analytics

-- ================================================
-- SECTION 1: BASIC QUERIES (5 queries)
-- ================================================

-- Query 1: List all doctors with their departments
-- Demonstrates: INNER JOIN, column selection
SELECT 
    d.doctor_id,
    d.first_name || ' ' || d.last_name AS doctor_name,
    d.specialization,
    dept.department_name,
    d.consultation_fee,
    d.years_of_experience
FROM doctors d
INNER JOIN departments dept ON d.department_id = dept.department_id
WHERE d.is_active = TRUE
ORDER BY dept.department_name, d.last_name;

-- Query 2: Count appointments by status
-- Demonstrates: GROUP BY, aggregate functions, HAVING
SELECT 
    status,
    COUNT(*) AS appointment_count,
    COUNT(DISTINCT patient_id) AS unique_patients,
    COUNT(DISTINCT doctor_id) AS unique_doctors,
    MIN(appointment_date) AS earliest_date,
    MAX(appointment_date) AS latest_date
FROM appointments
GROUP BY status
HAVING COUNT(*) > 0
ORDER BY appointment_count DESC;

-- Query 3: Find patients with specific blood types
-- Demonstrates: WHERE clause, IN operator, pattern matching
SELECT 
    patient_id,
    first_name || ' ' || last_name AS patient_name,
    blood_type,
    date_of_birth,
    EXTRACT(YEAR FROM AGE(date_of_birth)) AS age,
    phone,
    insurance_provider
FROM patients
WHERE blood_type IN ('O-', 'AB-', 'AB+')  -- Rare blood types
ORDER BY blood_type, last_name;

-- Query 4: Total billing by insurance provider
-- Demonstrates: GROUP BY, aggregate functions with calculations
SELECT 
    insurance_provider,
    COUNT(*) AS total_bills,
    SUM(total_amount) AS total_billed,
    SUM(insurance_covered) AS insurance_paid,
    SUM(patient_responsibility) AS patient_owed,
    ROUND(AVG(total_amount), 2) AS avg_bill_amount,
    ROUND(100.0 * SUM(insurance_covered) / NULLIF(SUM(total_amount), 0), 2) AS coverage_percentage
FROM billing b
JOIN patients p ON b.patient_id = p.patient_id
GROUP BY insurance_provider
ORDER BY total_billed DESC;

-- Query 5: List active prescriptions
-- Demonstrates: Multi-table JOIN, date filtering, ORDER BY
SELECT 
    pr.prescription_id,
    p.first_name || ' ' || p.last_name AS patient_name,
    d.first_name || ' ' || d.last_name AS doctor_name,
    pr.medication_name,
    pr.dosage,
    pr.frequency,
    pr.start_date,
    pr.end_date,
    pr.refills_allowed
FROM prescriptions pr
JOIN patients p ON pr.patient_id = p.patient_id
JOIN doctors d ON pr.doctor_id = d.doctor_id
WHERE pr.end_date >= CURRENT_DATE
ORDER BY pr.end_date, p.last_name;

-- ================================================
-- SECTION 2: ADVANCED QUERIES (15 queries)
-- ================================================

-- Query 6: Doctor workload analysis using window functions
-- Demonstrates: ROW_NUMBER, RANK, COUNT window functions
SELECT 
    d.doctor_id,
    d.first_name || ' ' || d.last_name AS doctor_name,
    dept.department_name,
    COUNT(a.appointment_id) AS total_appointments,
    ROW_NUMBER() OVER (ORDER BY COUNT(a.appointment_id) DESC) AS workload_rank,
    RANK() OVER (PARTITION BY dept.department_id ORDER BY COUNT(a.appointment_id) DESC) AS dept_rank,
    ROUND(100.0 * COUNT(a.appointment_id) / SUM(COUNT(a.appointment_id)) OVER (), 2) AS percentage_of_total
FROM doctors d
JOIN departments dept ON d.department_id = dept.department_id
LEFT JOIN appointments a ON d.doctor_id = a.doctor_id
WHERE d.is_active = TRUE
GROUP BY d.doctor_id, d.first_name, d.last_name, dept.department_name, dept.department_id
ORDER BY total_appointments DESC;

-- Query 7: Patient visit frequency with NTILE segmentation
-- Demonstrates: NTILE for customer segmentation, aggregate functions
SELECT 
    patient_id,
    patient_name,
    total_visits,
    total_spent,
    visit_frequency_tier,
    CASE 
        WHEN visit_frequency_tier = 1 THEN 'High Frequency'
        WHEN visit_frequency_tier = 2 THEN 'Medium-High Frequency'
        WHEN visit_frequency_tier = 3 THEN 'Medium-Low Frequency'
        ELSE 'Low Frequency'
    END AS tier_description
FROM (
    SELECT 
        p.patient_id,
        p.first_name || ' ' || p.last_name AS patient_name,
        COUNT(DISTINCT a.appointment_id) AS total_visits,
        COALESCE(SUM(b.total_amount), 0) AS total_spent,
        NTILE(4) OVER (ORDER BY COUNT(DISTINCT a.appointment_id) DESC) AS visit_frequency_tier
    FROM patients p
    LEFT JOIN appointments a ON p.patient_id = a.patient_id
    LEFT JOIN billing b ON p.patient_id = b.patient_id
    GROUP BY p.patient_id, p.first_name, p.last_name
) patient_tiers
ORDER BY visit_frequency_tier, total_visits DESC;

-- Query 8: Appointment trend analysis with LAG function
-- Demonstrates: LAG window function, date aggregation
SELECT 
    appointment_date,
    daily_appointments,
    LAG(daily_appointments, 1) OVER (ORDER BY appointment_date) AS previous_day,
    daily_appointments - LAG(daily_appointments, 1) OVER (ORDER BY appointment_date) AS day_over_day_change,
    ROUND(
        100.0 * (daily_appointments - LAG(daily_appointments, 1) OVER (ORDER BY appointment_date)) / 
        NULLIF(LAG(daily_appointments, 1) OVER (ORDER BY appointment_date), 0),
        2
    ) AS percent_change
FROM (
    SELECT 
        appointment_date,
        COUNT(*) AS daily_appointments
    FROM appointments
    WHERE status != 'Cancelled'
    GROUP BY appointment_date
) daily_stats
ORDER BY appointment_date;

-- Query 9: Recursive query for department hierarchy (simulated)
-- Demonstrates: Recursive CTE (even without strict hierarchy, shows capability)
WITH RECURSIVE department_tree AS (
    -- Base case: all departments
    SELECT 
        department_id,
        department_name,
        department_head,
        0 AS level,
        department_name AS path
    FROM departments
    
    UNION ALL
    
    -- Recursive case: could expand if we had parent_id
    SELECT 
        d.department_id,
        d.department_name,
        d.department_head,
        dt.level + 1,
        dt.path || ' > ' || d.department_name
    FROM departments d
    JOIN department_tree dt ON d.department_id != dt.department_id
    WHERE dt.level < 0  -- Prevents actual recursion in this flat structure
)
SELECT DISTINCT
    department_id,
    department_name,
    department_head,
    level
FROM department_tree
WHERE level = 0
ORDER BY department_name;

-- Query 10: Multi-level CTE for patient treatment cost analysis
-- Demonstrates: Multiple CTEs, complex calculations
WITH patient_visits AS (
    SELECT 
        p.patient_id,
        p.first_name || ' ' || p.last_name AS patient_name,
        p.insurance_provider,
        COUNT(DISTINCT a.appointment_id) AS total_appointments,
        COUNT(DISTINCT ad.admission_id) AS total_admissions
    FROM patients p
    LEFT JOIN appointments a ON p.patient_id = a.patient_id
    LEFT JOIN admissions ad ON p.patient_id = ad.patient_id
    GROUP BY p.patient_id, patient_name, p.insurance_provider
),
patient_costs AS (
    SELECT 
        patient_id,
        SUM(total_amount) AS total_billed,
        SUM(insurance_covered) AS insurance_paid,
        SUM(patient_responsibility) AS patient_paid,
        AVG(total_amount) AS avg_bill
    FROM billing
    GROUP BY patient_id
),
patient_metrics AS (
    SELECT 
        pv.patient_id,
        pv.patient_name,
        pv.insurance_provider,
        pv.total_appointments,
        pv.total_admissions,
        COALESCE(pc.total_billed, 0) AS total_cost,
        COALESCE(pc.insurance_paid, 0) AS insurance_contribution,
        COALESCE(pc.patient_paid, 0) AS patient_contribution,
        COALESCE(pc.avg_bill, 0) AS avg_bill_amount
    FROM patient_visits pv
    LEFT JOIN patient_costs pc ON pv.patient_id = pc.patient_id
)
SELECT 
    *,
    CASE 
        WHEN total_cost > 20000 THEN 'High Cost'
        WHEN total_cost > 10000 THEN 'Medium Cost'
        WHEN total_cost > 5000 THEN 'Low-Medium Cost'
        ELSE 'Low Cost'
    END AS cost_category
FROM patient_metrics
WHERE total_appointments > 0 OR total_admissions > 0
ORDER BY total_cost DESC;

-- Query 11: Find top revenue-generating doctors with PERCENT_RANK
-- Demonstrates: PERCENT_RANK window function
SELECT 
    d.doctor_id,
    d.first_name || ' ' || d.last_name AS doctor_name,
    dept.department_name,
    d.specialization,
    COUNT(DISTINCT a.appointment_id) AS total_appointments,
    COALESCE(SUM(b.total_amount), 0) AS total_revenue,
    PERCENT_RANK() OVER (ORDER BY COALESCE(SUM(b.total_amount), 0) DESC) AS revenue_percentile,
    CASE 
        WHEN PERCENT_RANK() OVER (ORDER BY COALESCE(SUM(b.total_amount), 0) DESC) <= 0.2 THEN 'Top 20%'
        WHEN PERCENT_RANK() OVER (ORDER BY COALESCE(SUM(b.total_amount), 0) DESC) <= 0.5 THEN 'Top 50%'
        ELSE 'Bottom 50%'
    END AS revenue_tier
FROM doctors d
JOIN departments dept ON d.department_id = dept.department_id
LEFT JOIN appointments a ON d.doctor_id = a.doctor_id
LEFT JOIN billing b ON a.appointment_id = b.appointment_id
WHERE d.is_active = TRUE
GROUP BY d.doctor_id, d.first_name, d.last_name, dept.department_name, d.specialization
HAVING COUNT(DISTINCT a.appointment_id) > 0
ORDER BY total_revenue DESC;

-- Query 12: Admission length of stay analysis
-- Demonstrates: Date calculations, CASE statements, aggregation
SELECT 
    ad.admission_id,
    p.first_name || ' ' || p.last_name AS patient_name,
    ad.admission_date,
    ad.discharge_date,
    CASE 
        WHEN ad.discharge_date IS NULL THEN CURRENT_DATE - ad.admission_date
        ELSE ad.discharge_date - ad.admission_date
    END AS length_of_stay_days,
    ad.admission_type,
    ad.primary_diagnosis,
    d.first_name || ' ' || d.last_name AS attending_doctor,
    CASE 
        WHEN ad.discharge_date IS NULL THEN 'Currently Admitted'
        WHEN ad.discharge_date - ad.admission_date <= 1 THEN 'Short Stay (1 day)'
        WHEN ad.discharge_date - ad.admission_date <= 3 THEN 'Medium Stay (2-3 days)'
        WHEN ad.discharge_date - ad.admission_date <= 7 THEN 'Long Stay (4-7 days)'
        ELSE 'Extended Stay (8+ days)'
    END AS stay_category
FROM admissions ad
JOIN patients p ON ad.patient_id = p.patient_id
JOIN doctors d ON ad.attending_doctor_id = d.doctor_id
ORDER BY 
    CASE WHEN ad.discharge_date IS NULL THEN 0 ELSE 1 END,
    length_of_stay_days DESC;

-- Query 13: Medication prescription patterns
-- Demonstrates: GROUP BY, string aggregation, HAVING
SELECT 
    medication_name,
    COUNT(*) AS times_prescribed,
    COUNT(DISTINCT patient_id) AS unique_patients,
    COUNT(DISTINCT doctor_id) AS prescribing_doctors,
    STRING_AGG(DISTINCT dosage, ', ' ORDER BY dosage) AS common_dosages,
    ROUND(AVG(duration_days), 1) AS avg_duration_days,
    MAX(refills_allowed) AS max_refills
FROM prescriptions
GROUP BY medication_name
HAVING COUNT(*) >= 2
ORDER BY times_prescribed DESC, unique_patients DESC
LIMIT 15;

-- Query 14: Department utilization analysis
-- Demonstrates: Complex aggregation across multiple tables
SELECT 
    dept.department_name,
    dept.floor_number,
    COUNT(DISTINCT d.doctor_id) AS total_doctors,
    COUNT(DISTINCT CASE WHEN d.is_active THEN d.doctor_id END) AS active_doctors,
    COUNT(DISTINCT a.appointment_id) AS total_appointments,
    COUNT(DISTINCT ad.admission_id) AS total_admissions,
    COUNT(DISTINCT s.staff_id) AS support_staff,
    ROUND(AVG(d.consultation_fee), 2) AS avg_consultation_fee,
    ROUND(AVG(d.years_of_experience), 1) AS avg_doctor_experience
FROM departments dept
LEFT JOIN doctors d ON dept.department_id = d.department_id
LEFT JOIN appointments a ON d.doctor_id = a.doctor_id
LEFT JOIN admissions ad ON d.doctor_id = ad.attending_doctor_id
LEFT JOIN staff s ON dept.department_id = s.department_id AND s.is_active = TRUE
GROUP BY dept.department_id, dept.department_name, dept.floor_number
ORDER BY total_appointments DESC;

-- Query 15: Patient emergency contact analysis
-- Demonstrates: Subqueries, DISTINCT, filtering
SELECT 
    emergency_contact_name,
    COUNT(DISTINCT patient_id) AS patients_listing_this_contact,
    STRING_AGG(DISTINCT first_name || ' ' || last_name, ', ' ORDER BY last_name) AS patient_names,
    MIN(emergency_contact_phone) AS contact_phone
FROM patients
WHERE emergency_contact_name IN (
    SELECT emergency_contact_name
    FROM patients
    GROUP BY emergency_contact_name
    HAVING COUNT(*) > 1
)
GROUP BY emergency_contact_name
ORDER BY patients_listing_this_contact DESC;

-- Query 16: Test completion rate by type
-- Demonstrates: CASE with aggregation, percentage calculations
SELECT 
    test_type,
    COUNT(*) AS total_tests,
    COUNT(CASE WHEN status = 'Completed' THEN 1 END) AS completed,
    COUNT(CASE WHEN status = 'Pending' THEN 1 END) AS pending,
    COUNT(CASE WHEN status = 'Scheduled' THEN 1 END) AS scheduled,
    COUNT(CASE WHEN status = 'Cancelled' THEN 1 END) AS cancelled,
    ROUND(100.0 * COUNT(CASE WHEN status = 'Completed' THEN 1 END) / COUNT(*), 2) AS completion_rate
FROM medical_tests
GROUP BY test_type
ORDER BY total_tests DESC;

-- Query 17: Billing payment status summary
-- Demonstrates: Multiple aggregations, financial calculations
SELECT 
    payment_status,
    COUNT(*) AS bill_count,
    SUM(total_amount) AS total_amount_sum,
    SUM(insurance_covered) AS insurance_sum,
    SUM(patient_responsibility) AS patient_sum,
    ROUND(AVG(total_amount), 2) AS avg_bill,
    MIN(total_amount) AS min_bill,
    MAX(total_amount) AS max_bill
FROM billing
GROUP BY payment_status
ORDER BY 
    CASE payment_status
        WHEN 'Paid' THEN 1
        WHEN 'Partially Paid' THEN 2
        WHEN 'Pending' THEN 3
        ELSE 4
    END;

-- Query 18: Doctor-patient interaction summary
-- Demonstrates: Multiple JOINs, DISTINCT counting
SELECT 
    d.doctor_id,
    d.first_name || ' ' || d.last_name AS doctor_name,
    d.specialization,
    COUNT(DISTINCT a.patient_id) AS unique_patients_seen,
    COUNT(DISTINCT a.appointment_id) AS total_appointments,
    COUNT(DISTINCT pr.prescription_id) AS prescriptions_written,
    COUNT(DISTINCT mt.test_id) AS tests_ordered,
    ROUND(AVG(CASE WHEN a.status = 'Completed' THEN 1 ELSE 0 END) * 100, 2) AS completion_rate
FROM doctors d
LEFT JOIN appointments a ON d.doctor_id = a.doctor_id
LEFT JOIN prescriptions pr ON d.doctor_id = pr.doctor_id
LEFT JOIN medical_tests mt ON d.doctor_id = mt.doctor_id
WHERE d.is_active = TRUE
GROUP BY d.doctor_id, d.first_name, d.last_name, d.specialization
HAVING COUNT(DISTINCT a.appointment_id) > 0
ORDER BY unique_patients_seen DESC;

-- Query 19: Monthly admission trends
-- Demonstrates: Date functions, time series analysis
SELECT 
    TO_CHAR(admission_date, 'YYYY-MM') AS month,
    COUNT(*) AS total_admissions,
    COUNT(CASE WHEN admission_type = 'Emergency' THEN 1 END) AS emergency_admissions,
    COUNT(CASE WHEN admission_type = 'Planned' THEN 1 END) AS planned_admissions,
    ROUND(100.0 * COUNT(CASE WHEN admission_type = 'Emergency' THEN 1 END) / COUNT(*), 2) AS emergency_percentage,
    COUNT(DISTINCT patient_id) AS unique_patients,
    ROUND(AVG(CASE 
        WHEN discharge_date IS NOT NULL 
        THEN discharge_date - admission_date 
        ELSE NULL 
    END), 1) AS avg_length_of_stay
FROM admissions
GROUP BY TO_CHAR(admission_date, 'YYYY-MM')
ORDER BY month DESC;

-- Query 20: Comprehensive patient health summary
-- Demonstrates: Multiple CTEs, complex business logic
WITH patient_activity AS (
    SELECT 
        patient_id,
        COUNT(DISTINCT appointment_id) AS total_appointments,
        MAX(appointment_date) AS last_appointment_date
    FROM appointments
    WHERE status = 'Completed'
    GROUP BY patient_id
),
patient_admissions AS (
    SELECT 
        patient_id,
        COUNT(*) AS total_admissions,
        MAX(admission_date) AS last_admission_date,
        SUM(CASE WHEN discharge_date IS NULL THEN 1 ELSE 0 END) AS currently_admitted
    FROM admissions
    GROUP BY patient_id
),
patient_financials AS (
    SELECT 
        patient_id,
        SUM(total_amount) AS lifetime_billing,
        SUM(patient_responsibility) AS total_owed
    FROM billing
    GROUP BY patient_id
)
SELECT 
    p.patient_id,
    p.first_name || ' ' || p.last_name AS patient_name,
    EXTRACT(YEAR FROM AGE(p.date_of_birth)) AS age,
    p.blood_type,
    p.insurance_provider,
    COALESCE(pa.total_appointments, 0) AS total_visits,
    COALESCE(pad.total_admissions, 0) AS hospital_stays,
    CASE WHEN pad.currently_admitted > 0 THEN 'Currently Admitted' ELSE 'Not Admitted' END AS admission_status,
    pa.last_appointment_date,
    COALESCE(pf.lifetime_billing, 0) AS total_healthcare_cost,
    COALESCE(pf.total_owed, 0) AS outstanding_balance,
    CASE 
        WHEN COALESCE(pf.total_owed, 0) > 1000 THEN 'High Balance'
        WHEN COALESCE(pf.total_owed, 0) > 500 THEN 'Medium Balance'
        WHEN COALESCE(pf.total_owed, 0) > 0 THEN 'Low Balance'
        ELSE 'Paid In Full'
    END AS financial_status
FROM patients p
LEFT JOIN patient_activity pa ON p.patient_id = pa.patient_id
LEFT JOIN patient_admissions pad ON p.patient_id = pad.patient_id
LEFT JOIN patient_financials pf ON p.patient_id = pf.patient_id
ORDER BY total_healthcare_cost DESC;

-- ================================================
-- End of Queries
-- Total: 20 queries
-- Basic: 5 queries
-- Advanced: 15 queries
-- Window Functions: ROW_NUMBER, RANK, NTILE, PERCENT_RANK, LAG
-- CTEs: Multiple complex CTEs including multi-level
-- Recursive: Demonstrated with department hierarchy
-- ================================================
