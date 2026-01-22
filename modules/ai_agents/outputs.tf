output "project_ids" {
  description = "Map of project IDs."
  value = {
    ai_sandbox       = module.prj_ai_sandbox.project_id
    agentic_workflow = module.prj_agentic_workflow.project_id
  }
}

output "agent_runner_sa_email" {
  description = "The email of the Agent Runner Service Account."
  value       = google_service_account.sa_agent_runner.email
}
