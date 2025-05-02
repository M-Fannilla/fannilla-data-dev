WITH user_profiles_events AS (
    SELECT *
    FROM {{ source('analytics', 'user_profiles') }}
)

SELECT
    event_published_at,
    user_id,
    gender,
    country,
FROM user_profiles_events