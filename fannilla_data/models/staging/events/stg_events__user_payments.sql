SELECT 
    payment_id,
    user_id,
    order_id,
    payment_method,
    amount,
    currency

FROM {{ source(var('fanilla_bq_dataset'), 'user_payments') }}