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
