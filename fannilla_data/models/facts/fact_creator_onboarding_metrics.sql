{{
    config(
        materialized='table',
        partition_by={
            'field': 'event_date',
            'data_type': 'date',
            'granularity': 'day'
        },
        cluster_by=['verification_status', 'rejection_reason']
    )
}}

WITH user_creator_status AS (
    SELECT
        user_id,
        created_at,
        email_verified_at,
        completed_signup_at,
        is_creator,
        platform_status
    FROM {{ ref('dim_users') }}
),

verification_events AS (
    SELECT
        user_id,
        verification_status,
        rejection_reason,
        varificator,
        event_published_at
    FROM {{ ref('stg_events__user_verifications') }}
),

creator_onboarding AS (
    SELECT
        u.user_id,
        DATE(u.created_at) as user_created_date,
        DATE(u.email_verified_at) as email_verified_date,
        DATE(u.completed_signup_at) as signup_completed_date,
        u.is_creator,
        u.platform_status,
        v.verification_status,
        v.rejection_reason,
        v.varificator,
        DATE(v.event_published_at) as verification_date,
        -- Calculate time to verification
        TIMESTAMP_DIFF(v.event_published_at, u.created_at, HOUR) as hours_to_verification,
        -- Calculate time to email verification
        TIMESTAMP_DIFF(u.email_verified_at, u.created_at, HOUR) as hours_to_email_verification,
        -- Calculate time to signup completion
        TIMESTAMP_DIFF(u.completed_signup_at, u.created_at, HOUR) as hours_to_signup_completion
    FROM user_creator_status u
    LEFT JOIN verification_events v
        ON u.user_id = v.user_id
),

daily_metrics AS (
    SELECT
        COALESCE(user_created_date, verification_date) as event_date,
        COUNT(DISTINCT user_id) as total_users,
        COUNT(DISTINCT CASE WHEN is_creator THEN user_id END) as total_creators,
        COUNT(DISTINCT CASE WHEN verification_status = 'approved' THEN user_id END) as approved_verifications,
        COUNT(DISTINCT CASE WHEN verification_status = 'rejected' THEN user_id END) as rejected_verifications,
        COUNT(DISTINCT CASE WHEN verification_status = 'pending' THEN user_id END) as pending_verifications,
        -- Average processing times
        AVG(hours_to_verification) as avg_verification_time,
        AVG(hours_to_email_verification) as avg_email_verification_time,
        AVG(hours_to_signup_completion) as avg_signup_completion_time,
        -- Rejection reasons
        STRING_AGG(DISTINCT rejection_reason) as rejection_reasons,
        -- Verificator distribution
        STRING_AGG(DISTINCT varificator) as verificators
    FROM creator_onboarding
    GROUP BY 1
)

SELECT
    event_date,
    total_users,
    total_creators,
    approved_verifications,
    rejected_verifications,
    pending_verifications,
    -- Calculate success rate
    SAFE_DIVIDE(approved_verifications, (approved_verifications + rejected_verifications)) as verification_success_rate,
    -- Time metrics
    avg_verification_time,
    avg_email_verification_time,
    avg_signup_completion_time,
    -- Additional metrics
    rejection_reasons,
    verificators,
    -- Daily new creators
    total_creators - LAG(total_creators) OVER (ORDER BY event_date) as new_creators_daily
FROM daily_metrics 