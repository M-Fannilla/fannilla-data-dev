WITH image_transcoder_busy AS (
    SELECT
        event_published_at,
        time_to_execute as request_queue_time,
        'image' AS transcoder_type
    FROM {{ source(var('fanilla_bq_dataset'), 'image_transcoder_busy') }}
),

video_transcoder_busy AS (
    SELECT
        event_published_at,
        time_to_execute as request_queue_time,
        'video' AS transcoder_type
    FROM {{ source(var('fanilla_bq_dataset'), 'video_transcoder_busy') }}
)

audio_transcoder_busy AS (
    SELECT
        event_published_at,
        time_to_execute as request_queue_time,
        'audio' AS transcoder_type
    FROM {{ source(var('fanilla_bq_dataset'), 'audio_transcoder_busy') }}
)

SELECT
    *,
FROM (
    SELECT * FROM image_transcoder_busy
    UNION ALL
    SELECT * FROM video_transcoder_busy
    UNION ALL
    SELECT * FROM audio_transcoder_busy
)
