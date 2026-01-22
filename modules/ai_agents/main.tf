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

# 8. AI Sandbox (Developer Playground)
module "prj_ai_sandbox" {
  source          = "../../modules/cff/project"
  billing_account = var.billing_account
  name            = "${var.prefix}-ai-sandbox"
  parent          = var.folder_id
  services = [
    "notebooks.googleapis.com",
    "aiplatform.googleapis.com",
    "compute.googleapis.com"
  ]
  shared_vpc_service_config = {
    host_project = var.host_project_id
    service_identity_iam = {
      "roles/compute.networkUser" = [
        "notebooks"
      ]
    }
  }
}

# 9. Agentic Workflow (Production Agent Host)
module "prj_agentic_workflow" {
  source          = "../../modules/cff/project"
  billing_account = var.billing_account
  name            = "${var.prefix}-agentic-workflow"
  parent          = var.folder_id
  services = [
    "aiplatform.googleapis.com",
    "discoveryengine.googleapis.com",
    "dialogflow.googleapis.com",
    "run.googleapis.com",
    "compute.googleapis.com"
  ]
  shared_vpc_service_config = {
    host_project = var.host_project_id
    service_identity_iam = {
      "roles/compute.networkUser" = [
        "cloudrun"
      ]
    }
  }
}

# --------------------------------------------------------------------------------
# Resources
# --------------------------------------------------------------------------------

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

  network = "projects/${var.host_project_id}/global/networks/${var.vpc_name}"
  subnet  = var.subnet_ids["ai_compute"]
  
  no_public_ip    = true
  no_proxy_access = false
}

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
