# How to destroy this created project
output "message" {
  value = "Created new project ${circleci_project.team_project.name} and restricted context."
}

output "project_url" {
  value = "https://app.circleci.com/projects/${circleci_project.team_project.slug}"
}

output "org_slug" {
  value = circleci_project.team_project.slug
}

output "context_url" {
  value = "https://app.circleci.com/settings/organization/${var.org_info.organization_slug}/contexts/${circleci_context.team_context.id}"
}

output "default_pipeline_id" {
  value = circleci_pipeline.default.id
}