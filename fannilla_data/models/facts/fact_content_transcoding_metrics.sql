{{
    config(
        materialized='table',
        partition_by={
            'field': 'event_date',
            'data_type': 'date',
            'granularity': 'day'
        },
        cluster_by=['transcoder_type', 'content_type']
    )
}}

WITH transcoding_success AS (
    SELECT
        DATE(event_published_at) as event_date,
        transcoder_type,
        content_type,
        execution_time,
        time_to_publish,
        number_of_results,
        COUNT(*) as success_count
    FROM {{ ref('stg_events__transcoder_success') }}
    GROUP BY 1, 2, 3, 4, 5, 6
),

transcoding_failures AS (
    SELECT
        DATE(event_published_at) as event_date,
        transcoder_type,
        exception_type,
        COUNT(*) as failure_count
    FROM {{ ref('stg_events__transcoder_failed') }}
    GROUP BY 1, 2, 3
),

transcoding_queue AS (
    SELECT
        DATE(event_published_at) as event_date,
        transcoder_type,
        AVG(request_queue_time) as avg_queue_time,
        COUNT(*) as queue_count
    FROM {{ ref('stg_events__transcoder_busy') }}
    GROUP BY 1, 2
),

daily_metrics AS (
    SELECT
        COALESCE(s.event_date, f.event_date, q.event_date) as event_date,
        COALESCE(s.transcoder_type, f.transcoder_type, q.transcoder_type) as transcoder_type,
        s.content_type,
        SUM(COALESCE(s.success_count, 0)) as successful_transcodes,
        SUM(COALESCE(f.failure_count, 0)) as failed_transcodes,
        AVG(COALESCE(s.execution_time, 0)) as avg_execution_time,
        AVG(COALESCE(s.time_to_publish, 0)) as avg_time_to_publish,
        AVG(COALESCE(q.avg_queue_time, 0)) as avg_queue_time,
        SUM(COALESCE(q.queue_count, 0)) as total_queued_requests,
        SUM(COALESCE(s.number_of_results, 0)) as total_processed_items
    FROM transcoding_success s
    FULL OUTER JOIN transcoding_failures f
        ON s.event_date = f.event_date
        AND s.transcoder_type = f.transcoder_type
    FULL OUTER JOIN transcoding_queue q
        ON COALESCE(s.event_date, f.event_date) = q.event_date
        AND COALESCE(s.transcoder_type, f.transcoder_type) = q.transcoder_type
    GROUP BY 1, 2, 3
)

SELECT
    event_date,
    transcoder_type,
    content_type,
    successful_transcodes,
    failed_transcodes,
    successful_transcodes + failed_transcodes as total_transcode_attempts,
    SAFE_DIVIDE(failed_transcodes, (successful_transcodes + failed_transcodes)) as failure_rate,
    avg_execution_time,
    avg_time_to_publish,
    avg_queue_time,
    total_queued_requests,
    total_processed_items
FROM daily_metrics 