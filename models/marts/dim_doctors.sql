{{ config(materialized='table', schema='gold') }}

SELECT
    doctor_name,
    hospital_name,
    COUNT(*)                    AS total_patients,
    COUNT(DISTINCT patient_name) AS unique_patients,
    AVG(billing_amount)         AS avg_billing_per_patient,
    SUM(billing_amount)         AS total_revenue,
    -- Most treated condition
    MODE(medical_condition)     AS most_treated_condition,
    AVG(length_of_stay_days)    AS avg_patient_stay
FROM {{ ref('int_care_health_cleaned') }}
GROUP BY doctor_name, hospital_name