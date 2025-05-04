{{
    config(
        materialized='table',
        partition_by={
            'field': 'cohort_date',
            'data_type': 'date',
            'granularity': 'month'
        },
        cluster_by=['cohort_date', 'user_id']
    )
}}

WITH user_first_events AS (
    SELECT
        user_id,
        MIN(event_timestamp) as first_event_timestamp,
        DATE_TRUNC(MIN(event_timestamp), MONTH) as cohort_date
    FROM {{ ref('fact_user_optin_events') }}
    WHERE event_type = 'signup'
    GROUP BY user_id
),

user_activity AS (
    SELECT
        user_id,
        event_timestamp,
        DATE_TRUNC(event_timestamp, MONTH) as activity_month
    FROM {{ ref('fact_user_optin_events') }}
    WHERE event_type != 'deleted'
),

cohort_activity AS (
    SELECT
        ufe.user_id,
        ufe.cohort_date,
        ua.activity_month,
        DATE_DIFF(ua.activity_month, ufe.cohort_date, MONTH) as months_since_cohort
    FROM user_first_events ufe
    LEFT JOIN user_activity ua
        ON ufe.user_id = ua.user_id
        AND ua.activity_month >= ufe.cohort_date
)

SELECT
    user_id,
    cohort_date,
    activity_month,
    months_since_cohort,
    CASE 
        WHEN months_since_cohort = 0 THEN 'Month 0'
        WHEN months_since_cohort = 1 THEN 'Month 1'
        WHEN months_since_cohort = 2 THEN 'Month 2'
        WHEN months_since_cohort = 3 THEN 'Month 3'
        WHEN months_since_cohort = 6 THEN 'Month 6'
        WHEN months_since_cohort = 12 THEN 'Month 12'
        ELSE 'Other'
    END as cohort_period
FROM cohort_activity
WHERE months_since_cohort IS NOT NULL 