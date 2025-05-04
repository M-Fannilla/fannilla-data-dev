{{
    config(
        materialized='table',
        partition_by={
            'field': 'date',
            'data_type': 'date',
            'granularity': 'day'
        },
        cluster_by=['date', 'location', 'age_segment', 'gender']
    )
}}

WITH daily_metrics AS (
    SELECT
        DATE_TRUNC(event_timestamp, DAY) as date,
        COUNT(DISTINCT CASE WHEN event_type = 'signup' THEN user_id END) as new_users,
        COUNT(DISTINCT CASE WHEN event_type = 'deleted' THEN user_id END) as churned_users,
        COUNT(DISTINCT user_id) as active_users
    FROM {{ ref('fact_user_optin_events') }}
    GROUP BY 1
),

cohort_metrics AS (
    SELECT
        cohort_date,
        cohort_period,
        COUNT(DISTINCT user_id) as cohort_size,
        COUNT(DISTINCT CASE WHEN activity_month = DATE_TRUNC(CURRENT_TIMESTAMP(), MONTH) THEN user_id END) as retained_users
    FROM {{ ref('int_user_cohorts') }}
    GROUP BY 1, 2
),

user_attributes AS (
    SELECT
        user_id,
        location,
        age_segment,
        gender,
        platform_status
    FROM {{ ref('dim_users') }}
)

SELECT
    dm.date,
    dm.new_users,
    dm.churned_users,
    dm.active_users,
    cm.cohort_date,
    cm.cohort_period,
    cm.cohort_size,
    cm.retained_users,
    ROUND(SAFE_DIVIDE(cm.retained_users, cm.cohort_size) * 100, 2) as retention_rate,
    ua.location,
    ua.age_segment,
    ua.gender,
    ua.platform_status,
    -- Rolling metrics
    SUM(dm.new_users) OVER (ORDER BY dm.date) as total_users,
    ROUND(SAFE_DIVIDE(SUM(dm.churned_users) OVER (ORDER BY dm.date), 
          SUM(dm.new_users) OVER (ORDER BY dm.date)) * 100, 2) as cumulative_churn_rate
FROM daily_metrics dm
LEFT JOIN cohort_metrics cm
    ON dm.date >= cm.cohort_date
LEFT JOIN user_attributes ua
    ON dm.date = DATE_TRUNC(CURRENT_TIMESTAMP(), DAY)
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12 