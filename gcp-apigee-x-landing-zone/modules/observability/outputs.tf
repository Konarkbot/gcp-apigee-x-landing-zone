output "log_bucket_id" { value = try(google_logging_project_bucket_config.audit[0].id, null) }
output "sink_writer_identity" { value = try(google_logging_project_sink.audit[0].writer_identity, null) }
