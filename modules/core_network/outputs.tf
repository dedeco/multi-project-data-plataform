output "host_project_id" {
  description = "The ID of the Shared VPC host project."
  value       = module.prj_shared_services.project_id
}

output "vpc_name" {
  description = "The name of the Shared VPC network."
  value       = module.vpc_main.network.name
}

output "vpc_self_link" {
  description = "The self link of the Shared VPC network."
  value       = module.vpc_main.network.self_link
}

output "subnet_ids" {
  description = "Map of subnet IDs."
  value       = {
    # We construct the subnet IDs manually or extract from module output if available.
    # The fabric module output structure is complex, but here we can return the ID map.
    orchestration = module.vpc_main.subnets["${var.region}/sb-orchestration"].id
    dataflow      = module.vpc_main.subnets["${var.region}/sb-dataflow"].id
    ai_compute    = module.vpc_main.subnets["${var.region}/sb-ai-compute"].id
    general       = module.vpc_main.subnets["${var.region}/sb-general"].id
  }
}
