-- models/marts/fct_admissions.sql
-- Purpose: Aggregated metrics for BI reporting
-- Materialization: TABLE

{{ config(materialized='table', schema='gold') }}

SELECT
    -- Dimensions
    medical_condition,
    admission_type,
    insurance_provider,
    severity_level,
    age_group,
    DATE_TRUNC('month', date_of_admission)  AS admission_month,

    -- Metrics
    COUNT(*)                                AS total_admissions,
    COUNT(DISTINCT patient_name)            AS unique_patients,
    AVG(length_of_stay_days)                AS avg_length_of_stay,
    SUM(billing_amount)                     AS total_billing,
    AVG(billing_amount)                     AS avg_billing,
    MAX(billing_amount)                     AS max_billing,
    MIN(billing_amount)                     AS min_billing,

    -- Anomaly count
    SUM(CASE WHEN billing_flag = 'ANOMALY'
             THEN 1 ELSE 0 END)             AS anomaly_count,

    CURRENT_TIMESTAMP()                     AS report_generated_at

FROM {{ ref('int_care_health_cleaned') }}
GROUP BY
    medical_condition, admission_type,
    insurance_provider, severity_level,
    age_group,
    DATE_TRUNC('month', date_of_admission)
ORDER BY admission_month DESC

