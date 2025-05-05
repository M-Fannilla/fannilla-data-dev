WITH image_transcoder_failed AS (
    SELECT
        event_published_at,
        exception_type,
        'image' AS transcoder_type
    FROM {{ source(var('fanilla_bq_dataset'), 'image_transcoder_failed') }}
),

video_transcoder_failed AS (
    SELECT
        event_published_at,
        exception_type,
        'video' AS transcoder_type
    FROM {{ source(var('fanilla_bq_dataset'), 'video_transcoder_failed') }}
)

audio_transcoder_success AS (
    SELECT
        event_published_at,
        exception_type,
        'audio' AS transcoder_type
    FROM {{ source(var('fanilla_bq_dataset'), 'audio_transcoder_failed') }}
)

SELECT
    *,
FROM (
    SELECT * FROM image_transcoder_failed
    UNION ALL
    SELECT * FROM video_transcoder_failed
    UNION ALL
    SELECT * FROM audio_transcoder_failed
)
