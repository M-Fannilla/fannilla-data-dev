SELECT * 
FROM {{ ref('stg_fnevents__user_profiles') }}


bq mk --transfer_config \
  --project_id=inance-capital \
  --data_source=postgres \
  --display_name="CloudSQL PostgreSQL → BQ users" \
  --target_dataset=fn_pg_raw \
  --params='{
    "instanceId": "inance-capital:europe-west4:fn-sandbox",
    "database":   "users",
    "query":      "SELECT * FROM users",
    "destination_table_name_template": "users",
    "write_disposition": "WRITE_TRUNCATE"
  }' \
  --schedule="every 24 hours"