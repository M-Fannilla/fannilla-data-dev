{{
    config(materialized='table')
}}


SELECT 
*
FROM EXTERNAL_QUERY(
    {{ 
        pg_conn_name(
            var('gcp_project'), 
            var('gcp_location'), 
            var('users_connection_id')
        ) 
    }},
    'SELECT 
        id,
        gender_id,
        email,
        date_of_birth,
        location,
        is_creator,
        email_verified_at,
        status_id,
        is_nsfw,
        wants_nsfw,
        completed_signup_at,
        created_at,
        deleted_at
    FROM users'
)