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

FROM {{ ref('stg_events__creator_posts') }}