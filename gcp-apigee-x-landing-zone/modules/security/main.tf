resource "google_kms_key_ring" "this" {
  count    = var.enable ? 1 : 0
  project  = var.project_id
  name     = var.key_ring_name
  location = var.region
}

resource "google_kms_crypto_key" "this" {
  count           = var.enable ? 1 : 0
  name            = var.crypto_key_name
  key_ring        = google_kms_key_ring.this[0].id
  rotation_period = "7776000s"

  lifecycle { prevent_destroy = true }
}

resource "google_secret_manager_secret" "this" {
  for_each  = var.enable ? var.secret_names : toset([])
  project   = var.project_id
  secret_id = each.value

  replication { auto {} }
}
