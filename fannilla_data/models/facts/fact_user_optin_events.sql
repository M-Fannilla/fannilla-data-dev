{{
    config(
        materialized='incremental',
        partition_by={
            'field': 'event_timestamp',
            'data_type': 'timestamp',
            'granularity': 'hour'
        },
        cluster_by=['user_id', 'event_type']
    )
}}

WITH user_events AS (
    SELECT
        user_id,
        created_at as event_timestamp,
        'signup' as event_type
    FROM {{ ref('stg_pg_users__users') }}

    UNION ALL

    SELECT
        user_id,
        email_verified_at as event_timestamp,
        'email_verified' as event_type
    FROM {{ ref('stg_pg_users__users') }}
    WHERE email_verified_at IS NOT NULL

    UNION ALL

    SELECT
        user_id,
        completed_signup_at as event_timestamp,
        'signup_completed' as event_type
    FROM {{ ref('stg_pg_users__users') }}
    WHERE completed_signup_at IS NOT NULL

    UNION ALL

    SELECT
        user_id,
        deleted_at as event_timestamp,
        'deleted' as event_type
    FROM {{ ref('stg_pg_users__users') }}
    WHERE deleted_at IS NOT NULL
)

SELECT
    user_id,
    event_timestamp,
    event_type,
    DATE_TRUNC(event_timestamp, HOUR) as event_hour,
    DATE_TRUNC(event_timestamp, DAY) as event_day,
    DATE_TRUNC(event_timestamp, WEEK) as event_week,
    DATE_TRUNC(event_timestamp, MONTH) as event_month
FROM user_events
WHERE event_timestamp IS NOT NULL 