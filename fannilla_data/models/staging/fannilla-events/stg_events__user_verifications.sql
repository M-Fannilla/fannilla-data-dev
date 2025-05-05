SELECT 
    user_id,
    rejection_reason,
    varificator,
    verification_status,

FROM {{ source(var('fanilla_bq_dataset'), 'user_verifications') }}