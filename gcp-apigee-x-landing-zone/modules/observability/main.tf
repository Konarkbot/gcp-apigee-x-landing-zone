resource "google_logging_project_bucket_config" "audit" {
  count            = var.enable ? 1 : 0
  project          = var.project_id
  location         = "global"
  bucket_id        = var.log_bucket_name
  retention_days   = var.retention_days
  enable_analytics = true
}

resource "google_logging_project_sink" "audit" {
  count                  = var.enable ? 1 : 0
  project                = var.project_id
  name                   = "${var.log_bucket_name}-sink"
  destination            = "logging.googleapis.com/projects/${var.project_id}/locations/global/buckets/${google_logging_project_bucket_config.audit[0].bucket_id}"
  filter                 = "log_id(\"cloudaudit.googleapis.com/activity\") OR log_id(\"cloudaudit.googleapis.com/system_event\") OR log_id(\"cloudaudit.googleapis.com/policy\")"
  unique_writer_identity = true
}
