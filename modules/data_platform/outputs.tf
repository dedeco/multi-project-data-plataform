output "project_ids" {
  description = "Map of project IDs."
  value = {
    landing          = module.prj_landing.project_id
    orchestration    = module.prj_orchestration.project_id
    load             = module.prj_load.project_id
    transformation   = module.prj_transformation.project_id
    datalake         = module.prj_datalake.project_id
    exposure         = module.prj_exposure.project_id
    common           = module.prj_common.project_id
  }
}

output "composer_env_name" {
  description = "The name of the Cloud Composer environment."
  value       = google_composer_environment.composer.name
}

output "analytics_hub_dataset_id" {
  description = "The ID of the Analytics Hub dataset."
  value       = google_bigquery_dataset.ds_analytics_hub.dataset_id
}
