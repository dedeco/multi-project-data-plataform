# GCP Data Platform & AI Agent Ecosystem

This repository contains the Modular Terraform foundation for a comprehensive **Google Cloud Data Platform** and **AI Agent Ecosystem**.

The infrastructure is built using best practices from the **Google Cloud Foundation Fabric (FAST)**, adapted into a modular architecture to support Data Lakes, AI Sandboxes, and Production Agentic Workflows.

## Architecture Overview

The platform is designed around a **Shared VPC** topology with a centralized Host Project and multiple attached Service Projects segregated by function.

### 1. Core Network (`modules/core_network`)
- **Host Project**: `prj-shared-services`
- **Network**: `vpc-main` (Standard Mode Shared VPC)
- **Subnets**:
  - `sb-orchestration`: For Cloud Composer & Airflow.
  - `sb-dataflow`: For Dataflow workers (ETL).
  - `sb-ai-compute`: For Vertex AI Notebooks & Agent workloads.
  - `sb-general`: For general purpose workloads.

### 2. Data Platform (`modules/data_platform`)
A suite of 7 Service Projects implementing a modern Data Mesh/Lakehouse pattern:
- **Ingestion**: `prj-landing` (BigQuery, GCS)
- **Scheduling**: `prj-orchestration` (Cloud Composer 2, Private IP)
- **Compute**: `prj-load` (Dataflow)
- **Transformation**: `prj-transformation` (BigQuery SQL)
- **Storage**: `prj-datalake` (BigQuery Datasets `L0`, `L1`, `L2` + GCS Buckets)
- **Consumption**: `prj-exposure` (Analytics Hub)
- **Governance**: `prj-common` (Data Catalog)

### 3. AI Agents (`modules/ai_agents`)
Dedicated environments for GenAI development and production agents:
- **Sandbox**: `prj-ai-sandbox`
  - User-Managed Notebooks for Data Scientists.
- **Production**: `prj-agentic-workflow`
  - Vertex AI, Agent Builder, Dialogflow, Cloud Run.
  - **Identities**: `sa-agent-runner` service account with cross-project access.

## Repository Structure

The codebase is modularized locally to ensure strict separation of concerns and ease of maintenance.

```text
.
├── main.tf                 # Root orchestrator calling the modules
├── variables.tf            # Global variables (Billling, Region, Folder)
├── outputs.tf              # Aggregated outputs (Project IDs, SAs)
├── modules/
│   ├── cff/                # Vendorized Google Cloud Foundation Fabric modules
│   │   ├── project/        # Project Factory
│   │   └── net-vpc/        # VPC Factory
│   ├── core_network/       # Host Project & Networking Logic
│   ├── data_platform/      # Data Mesh Projects & Resources
│   └── ai_agents/          # AI Ecosystem Projects & Resources
```

## Prerequisites

- **Terraform**: v1.5.0+
- **Google Cloud SDK**: Authenticated with a user/service account having `resourcemanager.folderAdmin`, `billing.user`, and `compute.networkAdmin` roles.
- **Inputs**:
  - A Billing Account ID.
  - A Folder ID to contain all projects.

## Deployment Guide

### 1. Clone & Initialize
This repository uses **local modules** (vendorized in `modules/cff`), so you do not need to authenticate to external git repositories during initialization.

```bash
git clone git@github.com:dedeco/multi-project-data-plataform.git
cd multi-project-data-plataform
terraform init
```

### 2. Plan Infrastructure
Create a `terraform.tfvars` file or pass variables via the command line:

```bash
terraform plan \
  -var="billing_account=012345-678901-ABCDEF" \
  -var="folder_id=1234567890" \
  -var="region=us-central1" \
  -var="admin_principal=user:admin@example.com" \
  -var="data_scientists_group=group:data-scientists@example.com"
```

### 3. Apply
```bash
terraform apply
```

## Security & IAM

- **Cross-Project Access**:
  - The **Agent Runner SA** (`sa-agent-runner` in `prj-agentic-workflow`) is granted `roles/bigquery.dataViewer` on the highly sensitive `analytics_hub` dataset in the `prj-exposure` project.
  - **Cloud Composer** in `prj-orchestration` has administrative rights (`roles/dataflow.admin`) to launch jobs in the compute project `prj-load`.
- **Network Security**:
  - All critical services (Composer, Notebooks) are deployed with Private IP configurations where applicable or attached to private subnets.

## License
Proprietary / Internal Use.
