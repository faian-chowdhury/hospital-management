# Hospital Management System - Dataset Guide

Student: FAIAN  
Date: October 9, 2025

This folder includes ten CSV files (277 rows total) that seed the hospital management database with realistic operational data. Each file matches the column definitions in `sql/schema.sql` and can be loaded via `sql/load_data.sql`.

| File | Rows | Summary |
| --- | ---: | --- |
| `departments.csv` | 12 | Emergency, Cardiology, Pediatrics, Oncology, and other hospital departments with floor assignments and extensions. |
| `doctors.csv` | 20 | Massachusetts-licensed physicians with specialties, experience, availability, and consultation fees. |
| `patients.csv` | 25 | Boston/Cambridge patients with demographics, insurance policies, and emergency contacts. |
| `appointments.csv` | 30 | Outpatient visits with reasons, scheduled times, and completion status. |
| `admissions.csv` | 15 | Inpatient stays covering emergency and planned admissions along with discharge details. |
| `prescriptions.csv` | 25 | Medication orders with dosage, frequency, duration, and prescribing doctor. |
| `medical_tests.csv` | 30 | Laboratory and imaging procedures, scheduling info, and result summaries. |
| `billing.csv` | 30 | Claims with insurance coverage, patient responsibility, payment method, and workflow status. |
| `staff.csv` | 15 | Non-physician staff (nursing, lab, radiology, pharmacy) with shifts and salary bands. |
| `audit_log.csv` | 15 | Representative audit events for HIPAA compliance testing. |

## Data Characteristics
- Names, addresses, and contact info follow Boston and Cambridge conventions with valid ZIP codes and 617 numbers.
- Clinical content spans emergency care, chronic disease management, preventative checkups, and specialty procedures.
- Insurance coverage assumptions use common blends (80/20 splits, deductible handling) to exercise billing constraints.
- Pending appointments, active admissions, and null discharge dates ensure triggers and queries account for edge cases.

## Loading Guidance
1. Run `sql/load_data.sql` from the repository root so the `\COPY` commands can locate the CSV files.
2. Load the datasets before enabling triggers to prevent historical records from recomputing billing totals or audit entries.
3. After the script finishes, execute the verification queries at the bottom of `sql/load_data.sql` to confirm row counts and referential integrity.

## Quality Checks
- Foreign keys resolve to existing parent rows; orphaned records are caught by the load script.
- Monetary columns use two decimal places, while dates and timestamps follow ISO 8601 (`YYYY-MM-DD HH24:MI:SS`).
- Blood types, gender codes, appointment statuses, and other enums adhere to the constraints declared in `schema.sql`.
- All text is stored as plain ASCII for broad tooling compatibility.

_Last Reviewed: October 2025_
