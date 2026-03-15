{{ config(materialized='table') }}

SELECT

    INITCAP(TRIM(name)) AS patient_name,

    age,

    UPPER(TRIM(gender)) AS gender,

    UPPER(TRIM(blood_type)) AS blood_type,

    INITCAP(TRIM(medical_condition)) AS medical_condition,

    TRY_TO_DATE(date_of_admission) AS admission_date,

    INITCAP(TRIM(doctor)) AS doctor_name,

    INITCAP(TRIM(hospital)) AS hospital_name,

    INITCAP(TRIM(insurance_provider)) AS insurance_provider,

    -- FIXED BILLING COLUMN
    CAST(ROUND(billing_amount) AS NUMBER(38,0)) AS billing_amount,

    room_number,

    INITCAP(TRIM(admission_type)) AS admission_type,

    TRY_TO_DATE(discharge_date) AS discharge_date,

    INITCAP(TRIM(medication)) AS medication,

    INITCAP(TRIM(test_results)) AS test_results

FROM {{ source('raw','care_health') }}