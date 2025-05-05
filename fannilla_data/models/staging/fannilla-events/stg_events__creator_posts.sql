SELECT 
    post_id,
    creator_id,
    post_audience,
    
    post_price,
    
    has_audio,
    has_video,
    has_image,

    hashtags,
    widget_id,
    
    expiration_date,
    scheduled_post_date

FROM {{ source(var('fanilla_bq_dataset'), 'creator_post') }}