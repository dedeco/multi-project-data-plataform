variable "billing_account" {
  description = "The ID of the billing account."
  type        = string
}

variable "folder_id" {
  description = "The ID of the folder."
  type        = string
}

variable "prefix" {
  description = "Prefix for resources."
  type        = string
}

variable "region" {
  description = "The region to deploy resources in."
  type        = string
}

variable "host_project_id" {
  description = "The ID of the host project."
  type        = string
}

variable "vpc_name" {
  description = "The name of the Shared VPC."
  type        = string
}

variable "subnet_ids" {
  description = "Map of subnet IDs."
  type        = map(string)
}
