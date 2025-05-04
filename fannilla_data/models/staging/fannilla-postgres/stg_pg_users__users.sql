{{
    config(materialized='view')
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
        date_of_birth,
        email,
        location,
        wants_nsfw,
        created_at,
        email_verified_at,
        completed_signup_at,
        deleted_at
        is_nsfw,
        is_creator,
        status_id,
    FROM users'
)