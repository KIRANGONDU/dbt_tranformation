-- INTERMEDIATE MODEL
-- Purpose : Heavy transformations — dedup, business rules,
--           calculations, null handling
-- Source  : STAGING.STG_CARE_HEALTH
-- Output  : SILVER.INT_CARE_HEALTH_CLEANED
-- Type    : INCREMENTAL (only new records each run)

{{ config(
    materialized     = 'incremental',
    unique_key       = ['patient_name', 'date_of_admission'],
    on_schema_change = 'append_new_columns'
) }}

WITH source AS (

    SELECT * FROM {{ ref('stg_care_health') }}

    -- INCREMENTAL FILTER
    -- Uses date_of_admission as watermark (no load_date in source)
    {% if is_incremental() %}
        WHERE date_of_admission > (
            SELECT MAX(date_of_admission) FROM {{ this }}
        )
    {% endif %}

),

-- DEDUPLICATION
-- Same patient admitted on same date = duplicate
-- Keep only the latest record
deduped AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY patient_name, date_of_admission
            ORDER BY date_of_admission DESC
        ) AS rn
    FROM source
    WHERE patient_name      IS NOT NULL
    AND   date_of_admission IS NOT NULL
),

-- BUSINESS RULES + CALCULATIONS
transformed AS (
    SELECT
        -- Patient info
        patient_name,
        age,
        gender,
        blood_type,
        medical_condition,

        -- Dates
        date_of_admission,
        discharge_date,

        -- CALCULATION 1: Length of stay in days
        DATEDIFF(
            'day',
            date_of_admission,
            discharge_date
        )                                           AS length_of_stay_days,

        -- BUSINESS RULE 1: Age group
        CASE
            WHEN age < 18  THEN 'Pediatric'
            WHEN age < 40  THEN 'Young Adult'
            WHEN age < 60  THEN 'Middle Aged'
            WHEN age < 75  THEN 'Senior'
            ELSE                'Elderly'
        END                                         AS age_group,

        -- Hospital info
        doctor_name,
        hospital_name,
        insurance_provider,
        room_number,
        admission_type,
        medication,
        test_results,

        -- Billing
        billing_amount,

        -- BUSINESS RULE 2: Flag billing anomalies
        CASE
            WHEN billing_amount < 100    THEN 'ANOMALY'
            WHEN billing_amount > 100000 THEN 'ANOMALY'
            ELSE                              'NORMAL'
        END                                         AS billing_flag,

        -- BUSINESS RULE 3: Severity based on test results
        CASE
            WHEN test_results = 'ABNORMAL'     THEN 'HIGH'
            WHEN test_results = 'INCONCLUSIVE' THEN 'MEDIUM'
            WHEN test_results = 'NORMAL'       THEN 'LOW'
            ELSE                                    'UNKNOWN'
        END                                         AS severity_level,

        -- BUSINESS RULE 4: Admission urgency label
        CASE
            WHEN admission_type = 'EMERGENCY' THEN 'Critical'
            WHEN admission_type = 'URGENT'    THEN 'High Priority'
            WHEN admission_type = 'ELECTIVE'  THEN 'Planned'
            ELSE                                   'Unknown'
        END                                         AS urgency_label,

        -- Audit columns (generated — not from source)
        CURRENT_TIMESTAMP()   AS load_date,
        'RAW.CARE_HEALTH'     AS source_file,
        CURRENT_TIMESTAMP()   AS dbt_updated_at

    FROM deduped
    WHERE rn = 1   -- keep only latest record per patient+date
)

SELECT * FROM transformed