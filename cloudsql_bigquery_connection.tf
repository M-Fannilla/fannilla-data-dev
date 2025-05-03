provider "google" {
  project = "inance-capital"
  region  = "europe-west4"
}

resource "google_bigquery_connection" "pg_conn_users" {
  connection_id = "pg_conn_users"
  location      = "europe-west4"
  friendly_name = "fn-sandbox-conn-users"
  description   = "Connection to PostgreSQL database for users"

  cloud_sql {
    instance_id = "inance-capital:europe-west4:fn-sandbox"
    database    = "users"
    type        = "POSTGRES"
    credential {
      username = "postgres"
      password = "3469"
    }
  }
}

resource "google_bigquery_connection" "pg_conn_payments" {
  connection_id = "pg_conn_payments"
  location      = "europe-west4"
  friendly_name = "fn-sandbox-conn-payments"
  description   = "Connection to PostgreSQL database for users"

  cloud_sql {
    instance_id = "inance-capital:europe-west4:fn-sandbox"
    database    = "payments"
    type        = "POSTGRES"
    credential {
      username = "postgres"
      password = "3469"
    }
  }
} 