output "host_project_id" {
  description = "The ID of the Shared VPC host project."
  value       = module.core_network.host_project_id
}

output "vpc_network_name" {
  description = "The name of the Shared VPC network."
  value       = module.core_network.vpc_name
}

output "service_project_ids" {
  description = "The IDs of all service projects."
  value = merge(
    module.data_platform.project_ids,
    module.ai_agents.project_ids
  )
}

output "agent_runner_sa_email" {
  description = "The email of the Agent Runner Service Account."
  value       = module.ai_agents.agent_runner_sa_email
}

output "composer_environment_name" {
  description = "The name of the Cloud Composer environment."
  value       = module.data_platform.composer_env_name
}
