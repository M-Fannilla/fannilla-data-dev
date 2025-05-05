{{
    config(materialized='view')
}}

SELECT 
    user_id,
    creator_id,
    content_id,
    content_type,
    interaction_type,

FROM {{ ref('stg_events__user_content_interactions') }}