terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
    }
  }
}

# Shared Services Project (Host Project)
module "prj_shared_services" {
  source          = "../../modules/cff/project"
  billing_account = var.billing_account
  name            = "${var.prefix}-shared-services"
  parent          = var.folder_id
  services = [
    "compute.googleapis.com",
    "dns.googleapis.com",
    "servicenetworking.googleapis.com",
    "container.googleapis.com",
  ]
  shared_vpc_host_config = {
    enabled = true
  }
}

# Shared VPC
module "vpc_main" {
  source     = "../../modules/cff/net-vpc"
  project_id = module.prj_shared_services.project_id
  name       = "${var.prefix}-vpc-main"
  
  subnets = [
    {
      name          = "sb-orchestration"
      ip_cidr_range = "10.0.1.0/24"
      region        = var.region
      secondary_ip_ranges = {
        pods     = "10.1.0.0/16"
        services = "10.2.0.0/16"
      }
    },
    {
      name          = "sb-dataflow"
      ip_cidr_range = "10.0.2.0/24"
      region        = var.region
    },
    {
      name          = "sb-ai-compute"
      ip_cidr_range = "10.0.3.0/24"
      region        = var.region
    },
    {
      name          = "sb-general"
      ip_cidr_range = "10.0.4.0/24"
      region        = var.region
    }
  ]
}
