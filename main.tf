terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0.0"
    }
  }
}

provider "google" {
  region = var.region
}

# 1. Core Network (Host Project + VPC)
module "core_network" {
  source = "./modules/core_network"

  billing_account = var.billing_account
  folder_id       = var.folder_id
  prefix          = var.prefix
  region          = var.region
}

# 2. Data Platform (Data Service Projects + Resources)
module "data_platform" {
  source = "./modules/data_platform"

  billing_account = var.billing_account
  folder_id       = var.folder_id
  prefix          = var.prefix
  region          = var.region
  
  host_project_id = module.core_network.host_project_id
  vpc_name        = module.core_network.vpc_name
  subnet_ids      = module.core_network.subnet_ids
  
  data_scientists_group = var.data_scientists_group
}

# 3. AI Agents (AI Service Projects + Resources)
module "ai_agents" {
  source = "./modules/ai_agents"

  billing_account = var.billing_account
  folder_id       = var.folder_id
  prefix          = var.prefix
  region          = var.region
  
  host_project_id = module.core_network.host_project_id
  vpc_name        = module.core_network.vpc_name
  subnet_ids      = module.core_network.subnet_ids
}

# --------------------------------------------------------------------------------
# Cross-Module Glue IAM
# --------------------------------------------------------------------------------

# Grant sa-agent-runner (from ai_agents) access to Analytics Hub Dataset (in data_platform)
resource "google_bigquery_dataset_iam_member" "agent_runner_analytics_hub_viewer" {
  project    = module.data_platform.project_ids["exposure"]
  dataset_id = module.data_platform.analytics_hub_dataset_id
  role       = "roles/bigquery.dataViewer"
  member     = "serviceAccount:${module.ai_agents.agent_runner_sa_email}"
}
