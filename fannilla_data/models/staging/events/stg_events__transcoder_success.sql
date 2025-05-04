WITH image_transcoder_success AS (
    SELECT
        event_published_at,
        exec_time as execution_time,
        content_type,
        time_to_publish,
        n_results as number_of_results,
        'image' AS transcoder_type
    FROM {{ source(var('fanilla_bq_dataset'), 'image_transcoder_success') }}
),

video_transcoder_success AS (
    SELECT
        event_published_at,
        exec_time as execution_time,
        content_type,
        time_to_publish,
        n_results as number_of_results,
        'video' AS transcoder_type
    FROM {{ source(var('fanilla_bq_dataset'), 'video_transcoder_success') }}
)

audio_transcoder_success AS (
    SELECT
        event_published_at,
        exec_time as execution_time,
        content_type,
        time_to_publish,
        n_results as number_of_results,
        'audio' AS transcoder_type
    FROM {{ source(var('fanilla_bq_dataset'), 'audio_transcoder_success') }}
)

SELECT
    *,
FROM (
    SELECT * FROM image_transcoder_success
    UNION ALL
    SELECT * FROM video_transcoder_success
    UNION ALL
    SELECT * FROM audio_transcoder_success
)
