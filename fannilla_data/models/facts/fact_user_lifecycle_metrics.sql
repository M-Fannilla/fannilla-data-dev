{{
    config(
        materialized='table',
        partition_by={
            'field': 'event_date',
            'data_type': 'date',
            'granularity': 'day'
        },
        cluster_by=['account_status', 'account_state']
    )
}}

WITH user_status_changes AS (
    SELECT
        user_id,
        created_at,
        email_verified_at,
        completed_signup_at,
        deleted_at,
        platform_status,
        -- Calculate account age in days
        DATE_DIFF(CURRENT_DATE(), DATE(created_at), DAY) as account_age_days,
        -- Determine if account is active
        CASE 
            WHEN deleted_at IS NULL THEN TRUE
            ELSE FALSE
        END as is_active,
        -- Determine account state
        CASE
            WHEN deleted_at IS NOT NULL THEN 'deleted'
            WHEN email_verified_at IS NULL THEN 'unverified'
            WHEN completed_signup_at IS NULL THEN 'incomplete'
            ELSE 'active'
        END as account_state,
        -- Calculate time to email verification
        TIMESTAMP_DIFF(email_verified_at, created_at, HOUR) as hours_to_email_verification,
        -- Calculate time to signup completion
        TIMESTAMP_DIFF(completed_signup_at, created_at, HOUR) as hours_to_signup_completion,
        -- Calculate time to deletion (if applicable)
        TIMESTAMP_DIFF(deleted_at, created_at, DAY) as days_to_deletion
    FROM {{ ref('dim_users') }}
),

daily_metrics AS (
    SELECT
        DATE(created_at) as event_date,
        -- Account creation metrics
        COUNT(DISTINCT user_id) as new_accounts,
        -- Account state metrics
        COUNT(DISTINCT CASE WHEN account_state = 'active' THEN user_id END) as active_accounts,
        COUNT(DISTINCT CASE WHEN account_state = 'unverified' THEN user_id END) as unverified_accounts,
        COUNT(DISTINCT CASE WHEN account_state = 'incomplete' THEN user_id END) as incomplete_accounts,
        COUNT(DISTINCT CASE WHEN account_state = 'deleted' THEN user_id END) as deleted_accounts,
        -- Platform status distribution
        COUNT(DISTINCT CASE WHEN platform_status = 'active' THEN user_id END) as platform_active_users,
        COUNT(DISTINCT CASE WHEN platform_status = 'suspended' THEN user_id END) as suspended_users,
        COUNT(DISTINCT CASE WHEN platform_status = 'banned' THEN user_id END) as banned_users,
        -- Time metrics
        AVG(hours_to_email_verification) as avg_hours_to_email_verification,
        AVG(hours_to_signup_completion) as avg_hours_to_signup_completion,
        AVG(days_to_deletion) as avg_days_to_deletion,
        -- Account age metrics
        AVG(account_age_days) as avg_account_age_days,
        -- Deletion metrics
        COUNT(DISTINCT CASE WHEN deleted_at IS NOT NULL THEN user_id END) as total_deleted_accounts,
        -- Calculate daily deletion rate
        COUNT(DISTINCT CASE 
            WHEN DATE(deleted_at) = DATE(created_at) 
            THEN user_id 
        END) as same_day_deletions
    FROM user_status_changes
    GROUP BY 1
),

cumulative_metrics AS (
    SELECT
        event_date,
        new_accounts,
        active_accounts,
        unverified_accounts,
        incomplete_accounts,
        deleted_accounts,
        platform_active_users,
        suspended_users,
        banned_users,
        avg_hours_to_email_verification,
        avg_hours_to_signup_completion,
        avg_days_to_deletion,
        avg_account_age_days,
        total_deleted_accounts,
        same_day_deletions,
        -- Calculate cumulative metrics
        SUM(new_accounts) OVER (ORDER BY event_date) as cumulative_new_accounts,
        SUM(deleted_accounts) OVER (ORDER BY event_date) as cumulative_deleted_accounts,
        -- Calculate retention rate
        SAFE_DIVIDE(
            active_accounts,
            SUM(new_accounts) OVER (ORDER BY event_date)
        ) as retention_rate,
        -- Calculate deletion rate
        SAFE_DIVIDE(
            deleted_accounts,
            SUM(new_accounts) OVER (ORDER BY event_date)
        ) as daily_deletion_rate
    FROM daily_metrics
)

SELECT
    event_date,
    -- Daily metrics
    new_accounts,
    active_accounts,
    unverified_accounts,
    incomplete_accounts,
    deleted_accounts,
    platform_active_users,
    suspended_users,
    banned_users,
    -- Time metrics
    avg_hours_to_email_verification,
    avg_hours_to_signup_completion,
    avg_days_to_deletion,
    avg_account_age_days,
    -- Deletion metrics
    total_deleted_accounts,
    same_day_deletions,
    -- Cumulative metrics
    cumulative_new_accounts,
    cumulative_deleted_accounts,
    -- Rate metrics
    retention_rate,
    daily_deletion_rate,
    -- Calculate churn rate (deletions / active accounts)
    SAFE_DIVIDE(deleted_accounts, active_accounts) as daily_churn_rate
FROM cumulative_metrics 