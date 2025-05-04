SELECT 
    payment_id,
    status_id,
    decline_reason,

 FROM {{ source(var('fanilla_bq_dataset'), 'user_payment_status') }}