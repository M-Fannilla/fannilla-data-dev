SELECT 
    user_id,
    creator_id,
    content_id,
    content_type,
    interaction_type,

FROM {{ source(var('fanilla_bq_dataset'), 'content_interactions') }}