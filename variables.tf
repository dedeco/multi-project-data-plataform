variable "billing_account" {
  description = "The ID of the billing account to associate projects with."
  type        = string
}

variable "folder_id" {
  description = "The ID of the folder to create projects in."
  type        = string
}

variable "prefix" {
  description = "Prefix for resources."
  type        = string
  default     = "dp"
}

variable "region" {
  description = "The region to deploy resources in."
  type        = string
  default     = "us-central1"
}

variable "admin_principal" {
  description = "Admin principal for IAM bindings (e.g. group:admins@example.com or user:admin@example.com)."
  type        = string
}

variable "data_scientists_group" {
  description = "Group email for data scientists."
  type        = string
  default     = "group:gcp-data-scientists@example.com"
}
