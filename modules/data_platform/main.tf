terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
    }
  }
}

# --------------------------------------------------------------------------------
# Service Projects
# --------------------------------------------------------------------------------

# 1. Landing (Ingestion)
module "prj_landing" {
  source          = "../../modules/cff/project"
  billing_account = var.billing_account
  name            = "${var.prefix}-landing"
  parent          = var.folder_id
  services        = ["bigquery.googleapis.com", "storage.googleapis.com"]
  shared_vpc_service_config = {
    host_project = var.host_project_id
    service_identity_iam = {
      "roles/compute.networkUser" = [
        "cloudservices", "container-engine"
      ]
    }
  }
}

# 2. Orchestration (Scheduling)
module "prj_orchestration" {
  source          = "../../modules/cff/project"
  billing_account = var.billing_account
  name            = "${var.prefix}-orchestration"
  parent          = var.folder_id
  services        = ["composer.googleapis.com", "compute.googleapis.com"]
  shared_vpc_service_config = {
    host_project = var.host_project_id
    service_identity_iam = {
      "roles/compute.networkUser" = [
        "cloudservices", "composer"
      ]
    }
  }
}

# 3. Load (Compute)
module "prj_load" {
  source          = "../../modules/cff/project"
  billing_account = var.billing_account
  name            = "${var.prefix}-load"
  parent          = var.folder_id
  services        = ["dataflow.googleapis.com", "compute.googleapis.com", "storage.googleapis.com"]
  shared_vpc_service_config = {
    host_project = var.host_project_id
    service_identity_iam = {
      "roles/compute.networkUser" = [
        "dataflow"
      ]
    }
  }
}

# 4. Transformation (SQL Logic)
module "prj_transformation" {
  source          = "../../modules/cff/project"
  billing_account = var.billing_account
  name            = "${var.prefix}-transformation"
  parent          = var.folder_id
  services        = ["bigquery.googleapis.com"]
  shared_vpc_service_config = {
    host_project = var.host_project_id
  }
}

# 5. Datalake (Storage)
module "prj_datalake" {
  source          = "../../modules/cff/project"
  billing_account = var.billing_account
  name            = "${var.prefix}-datalake"
  parent          = var.folder_id
  services        = ["bigquery.googleapis.com", "storage.googleapis.com"]
  shared_vpc_service_config = {
    host_project = var.host_project_id
  }
}

# 6. Exposure (Consumption)
module "prj_exposure" {
  source          = "../../modules/cff/project"
  billing_account = var.billing_account
  name            = "${var.prefix}-exposure"
  parent          = var.folder_id
  services        = ["bigquery.googleapis.com", "analyticshub.googleapis.com"]
  shared_vpc_service_config = {
    host_project = var.host_project_id
  }
}

# 7. Common (Governance)
module "prj_common" {
  source          = "../../modules/cff/project"
  billing_account = var.billing_account
  name            = "${var.prefix}-common"
  parent          = var.folder_id
  services        = ["bigquery.googleapis.com", "datacatalog.googleapis.com"]
  shared_vpc_service_config = {
    host_project = var.host_project_id
  }
}

# --------------------------------------------------------------------------------
# Resources
# --------------------------------------------------------------------------------

# Cloud Composer 2
resource "google_composer_environment" "composer" {
  project = module.prj_orchestration.project_id
  name    = "composer-main"
  region  = var.region

  config {
    software_config {
      image_version = "composer-3-airflow-2"
    }
    
    node_config {
      network    = "projects/${var.host_project_id}/global/networks/${var.vpc_name}"
      subnetwork = var.subnet_ids["orchestration"]
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

# Composer SA needs roles/dataflow.admin on prj-load (Cross-project, but within data module scope conceptually OK here or root. 
# Since we have prj-load ID here, we can do it here.)
resource "google_project_iam_member" "composer_dataflow_admin" {
  project = module.prj_load.project_id
  role    = "roles/dataflow.admin"
  member  = "serviceAccount:${google_service_account.sa_composer.email}"
}

resource "google_project_iam_member" "composer_sa_user_load" {
  project = module.prj_load.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.sa_composer.email}"
}


# BigQuery Datasets & Buckets
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

resource "google_bigquery_dataset" "ds_analytics_hub" {
  project    = module.prj_exposure.project_id
  dataset_id = "analytics_hub"
  location   = var.region
}

# Data Scientists viewer role on DL
resource "google_project_iam_member" "data_scientists_datalake_viewer" {
  project = module.prj_datalake.project_id
  role    = "roles/bigquery.dataViewer"
  member  = var.data_scientists_group
}
