{{
    config(materialized='ephemeral'
}}

SELECT 
    event_publoshed_at AS event_timestamp,
    user_id,
    event_type,

FROM {{ ref('stg_events__user_optins') }}