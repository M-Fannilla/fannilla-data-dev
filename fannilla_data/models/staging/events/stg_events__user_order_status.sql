SELECT 
    order_id,
    user_id,
    subtotal_amount,
    order_type,
    item_id,

FROM {{ source(var('fanilla_bq_dataset'), 'user_order') }}