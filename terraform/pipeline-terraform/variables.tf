variable "org_info" {
  type = object({
    organization_id   = string
    project_provider  = string #usually `circleci`
    organization_slug = string
  })
}

variable "platform_configs_repo_id" {
  description = "The external repository ID for platform-team-configs (where config templates are stored)"
  type        = string
  default     = "998922484"  # CircleCI-Labs/platform-team-configs
}

variable "appteam_pipeline_profiles" {
  description = "Collection on restricted contexts to manage."
  type = object({
    application_name     = string
    application_template = string
    external_repo_id     = string #from Github, not the same as name
    external_template_repo_id = string
    context_name         = string
    # Provided as type:value pairs
    context_restrictions = map(string)
    # reference the value ina  sensitive set defined below, otherwise we can't loop values.
    context_variables = set(string)
  })


}

variable "app_team_passwords" {
  sensitive = true
  type      = map(string)
  default = {
    "deployer_name"   = "app_team_account"
    "deployer_secret" = "bad_s3cret"
  }
}

variable "context_restrictions" {
  type = map(string)
  default = {
    "default_branch_only" = "git.branch == \"main\""
  }
}