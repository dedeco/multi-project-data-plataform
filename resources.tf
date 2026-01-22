# --------------------------------------------------------------------------------
# AI & Agent Resources
# --------------------------------------------------------------------------------

# Service Account for Agent Runner in prj-agentic-workflow
resource "google_service_account" "sa_agent_runner" {
  project      = module.prj_agentic_workflow.project_id
  account_id   = "sa-agent-runner"
  display_name = "Agent Runner Service Account"
}

# Grant Vertex AI User and Log Writer to the Agent Runner SA
resource "google_project_iam_member" "agent_runner_vertex_user" {
  project = module.prj_agentic_workflow.project_id
  role    = "roles/aiplatform.user"
  member  = "serviceAccount:${google_service_account.sa_agent_runner.email}"
}

resource "google_project_iam_member" "agent_runner_log_writer" {
  project = module.prj_agentic_workflow.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.sa_agent_runner.email}"
}

# AI Sandbox Notebook
resource "google_notebooks_instance" "sandbox_notebook" {
  project      = module.prj_ai_sandbox.project_id
  name         = "sandbox-notebook"
  location     = "${var.region}-a"
  machine_type = "e2-medium"
  
  vm_image {
    project      = "deeplearning-platform-release"
    image_family = "common-cpu"
  }

  network = module.vpc_main.network.self_link
  subnet  = module.vpc_main.subnets["${var.region}/sb-ai-compute"].self_link
  
  no_public_ip    = true
  no_proxy_access = false
}

# --------------------------------------------------------------------------------
# Data Platform Resources
# --------------------------------------------------------------------------------

# Cloud Composer 2 in prj-orchestration
resource "google_composer_environment" "composer" {
  project = module.prj_orchestration.project_id
  name    = "composer-main"
  region  = var.region

  config {
    software_config {
      image_version = "composer-3-airflow-2"
    }
    
    node_config {
      network    = module.vpc_main.network.id
      subnetwork = module.vpc_main.subnets["${var.region}/sb-orchestration"].id
      service_account = google_service_account.sa_composer.email
    }
  }
  
  depends_on = [module.prj_orchestration]
}

resource "google_service_account" "sa_composer" {
  project      = module.prj_orchestration.project_id
  account_id   = "sa-composer"
  display_name = "Composer Service Account"
}

resource "google_project_iam_member" "composer_worker" {
  project = module.prj_orchestration.project_id
  role    = "roles/composer.worker"
  member  = "serviceAccount:${google_service_account.sa_composer.email}"
}

# BigQuery Datasets in prj-datalake
resource "google_bigquery_dataset" "ds_l0" {
  project    = module.prj_datalake.project_id
  dataset_id = "L0_raw"
  location   = var.region
}

resource "google_bigquery_dataset" "ds_l1" {
  project    = module.prj_datalake.project_id
  dataset_id = "L1_enriched"
  location   = var.region
}

resource "google_bigquery_dataset" "ds_l2" {
  project    = module.prj_datalake.project_id
  dataset_id = "L2_curated"
  location   = var.region
}

# GCS Buckets in prj-datalake
resource "google_storage_bucket" "bkt_l0" {
  project       = module.prj_datalake.project_id
  name          = "${module.prj_datalake.project_id}-l0-raw"
  location      = var.region
  force_destroy = true
}

resource "google_storage_bucket" "bkt_l1" {
  project       = module.prj_datalake.project_id
  name          = "${module.prj_datalake.project_id}-l1-enriched"
  location      = var.region
  force_destroy = true
}

resource "google_storage_bucket" "bkt_l2" {
  project       = module.prj_datalake.project_id
  name          = "${module.prj_datalake.project_id}-l2-curated"
  location      = var.region
  force_destroy = true
}

# Analytics Hub Dataset in prj-exposure
resource "google_bigquery_dataset" "ds_analytics_hub" {
  project    = module.prj_exposure.project_id
  dataset_id = "analytics_hub"
  location   = var.region
}
