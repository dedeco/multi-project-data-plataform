# --------------------------------------------------------------------------------
# Cross-Project IAM Strategy
# --------------------------------------------------------------------------------

# 1. Agent Data: Grant sa-agent-runner (prj-agentic-workflow) roles/bigquery.dataViewer on analytics_hub dataset (prj-exposure)
resource "google_bigquery_dataset_iam_member" "agent_runner_analytics_hub_viewer" {
  project    = module.prj_exposure.project_id
  dataset_id = google_bigquery_dataset.ds_analytics_hub.dataset_id
  role       = "roles/bigquery.dataViewer"
  member     = "serviceAccount:${google_service_account.sa_agent_runner.email}"
}

# 2. Sandbox Data: Grant gcp-data-scientists roles/bigquery.dataViewer on prj-datalake
resource "google_project_iam_member" "data_scientists_datalake_viewer" {
  project = module.prj_datalake.project_id
  role    = "roles/bigquery.dataViewer"
  member  = var.data_scientists_group
}

# 3. Orchestration Load: Composer SA needs roles/dataflow.admin on prj-load
resource "google_project_iam_member" "composer_dataflow_admin" {
  project = module.prj_load.project_id
  role    = "roles/dataflow.admin"
  member  = "serviceAccount:${google_service_account.sa_composer.email}"
}

# Composer SA also needs to be a Service Account User in prj-load to launch Dataflow jobs
resource "google_project_iam_member" "composer_sa_user_load" {
  project = module.prj_load.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.sa_composer.email}"
}

# Composer SA needs access to the Shared VPC subnets (sb-dataflow) from the host project? 
# No, Dataflow workers run in the subnets. The SA needs compute.networkUser on the host project subnets if strictly restricted.
# The service projects (prj-load) already have compute.networkUser for the cloudservices/dataflow SAs via main.tf configuration.
