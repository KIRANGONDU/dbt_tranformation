{{ config(materialized='table', schema='gold') }}

SELECT
    patient_name,
    age,
    age_group,
    gender,
    blood_type,
    COUNT(*)                    AS total_admissions,
    SUM(billing_amount)         AS total_billed,
    AVG(billing_amount)         AS avg_billing,
    MIN(date_of_admission)      AS first_admission,
    MAX(date_of_admission)      AS last_admission,
    -- Most common condition
    MODE(medical_condition)     AS most_common_condition,
    -- Most used insurance
    MODE(insurance_provider)    AS primary_insurance
FROM {{ ref('int_care_health_cleaned') }}
GROUP BY patient_name, age, age_group, gender, blood_type