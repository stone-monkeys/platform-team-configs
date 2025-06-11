resource "circleci_project" "team_project" {
  #for_each = toset(var.appteam_pipeline_profiles)
  name             = var.appteam_pipeline_profiles.application_name
  organization_id  = var.org_info.organization_id
  project_provider = var.org_info.project_provider
}



resource "circleci_context" "team_context" {
  #for_each = toset(var.appteam_pipeline_profiles)
  name            = var.appteam_pipeline_profiles.context_name
  organization_id = var.org_info.organization_id
}


resource "circleci_context_restriction" "context_restrictions" {
  for_each   = var.appteam_pipeline_profiles.context_restrictions
  context_id = circleci_context.team_context.id
  type       = each.key
  value      = (each.key == "project") ? circleci_project.team_project.id : var.context_restrictions[each.value]
}

resource "circleci_context_environment_variable" "team_variables" {
  #loop all created contexts, and look up the set of values to inject
  for_each = var.appteam_pipeline_profiles.context_variables


  context_id = circleci_context.team_context.id
  name       = each.value
  value      = var.app_team_passwords[each.key]
}

resource "circleci_pipeline" "default" {
  name                             = "default"
  description                      = "Run on all commits"
  project_id                       = circleci_project.team_project.id
  checkout_source_provider         = "github_app"
  checkout_source_repo_external_id = var.appteam_pipeline_profiles.external_repo_id
  config_source_file_path          = "config-templates/python/config.yml"
  config_source_provider           = "github_app"
  config_source_repo_external_id   = var.appteam_pipeline_profiles.external_template_repo_id
}

resource "circleci_trigger" "default" {
  name                          = "default"
  description                   = "Default trigger created by Platform Team"
  pipeline_id                   = circleci_pipeline.default.id
  project_id                    = circleci_project.team_project.id
  event_source_provider         = "github_app"
  event_source_repo_external_id = var.appteam_pipeline_profiles.external_repo_id
  event_preset                  = "all-pushes"
  config_ref                    = ""
  checkout_ref                  = ""
}