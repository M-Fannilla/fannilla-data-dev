{{ 
    config(materialized='table'),
    cluster_by=[
        'gender_id',
        'age_segment',
        'location',
        'email_provider',
        ],
}}

SELECT
    id as user_id,
    gender_id,
    SPLIT(SPLIT(email, '@')[OFFSET(1)], '.')[OFFSET(0)] AS email_provider,
    EXTRACT(YEAR FROM CURRENT_DATE()) - EXTRACT(YEAR FROM date_of_birth) AS age,
    CASE
        WHEN EXTRACT(YEAR FROM CURRENT_DATE()) - EXTRACT(YEAR FROM date_of_birth) BETWEEN 18 AND 24 THEN '18-24'
        WHEN EXTRACT(YEAR FROM CURRENT_DATE()) - EXTRACT(YEAR FROM date_of_birth) BETWEEN 25 AND 34 THEN '25-34'
        WHEN EXTRACT(YEAR FROM CURRENT_DATE()) - EXTRACT(YEAR FROM date_of_birth) BETWEEN 35 AND 44 THEN '35-44'
        WHEN EXTRACT(YEAR FROM CURRENT_DATE()) - EXTRACT(YEAR FROM date_of_birth) BETWEEN 45 AND 54 THEN '45-54'
        WHEN EXTRACT(YEAR FROM CURRENT_DATE()) - EXTRACT(YEAR FROM date_of_birth) BETWEEN 55 AND 64 THEN '55-64'
        ELSE '65+'
    END AS age_segment,
    location,

    -- preferences
    wants_nsfw,

    -- user platform progression
    created_at,
    email_verified_at,
    completed_signup_at,
    deleted_at,

    -- creator
    is_nsfw,
    is_creator,

    -- user status
    status_id,

FROM {{ ref('stg_pg_users__users') }}