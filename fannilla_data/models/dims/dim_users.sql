{{ 
    config(materialized='table'),
    partition_by={
        'field': 'created_at',
        'data_type': 'timestamp',
        'granularity': 'hour',
    },
    cluster_by=[
        'platform_status',
        'gender',
        'age_segment',
        'location',
        ],
}}

SELECT
    id as user_id,

    -- physical attributes
    {{ 
        map_pg_lookup_over_ids('gender_id', var('users_connection_id'), 'genders') 
    }} AS gender,

    -- email provider
    SPLIT(SPLIT(email, '@')[OFFSET(1)], '.')[OFFSET(0)] AS email_provider,

    -- user locations - what about this?
    location,

    -- preferences there is missing piece from about users current preferences. Which table to use?
    wants_nsfw,

    -- user platform progression
    created_at,
    email_verified_at,
    completed_signup_at,
    deleted_at,

    -- creator
    is_nsfw,
    is_creator,

    -- user status, maps to user_statuses
    {{ 
        map_pg_lookup_over_ids('status_id', var('users_connection_id'), 'user_statuses') 
    }} AS platform_status,

FROM {{ ref('stg_pg_users__users') }}