output "kms_key_id" { value = try(google_kms_crypto_key.this[0].id, null) }
output "secret_ids" { value = { for k, v in google_secret_manager_secret.this : k => v.id } }
