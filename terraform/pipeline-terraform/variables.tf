variable "org_info" {
  type = object({
    organization_id   = string
    project_provider  = string #usually `circleci`
    organization_slug = string
  })
}

variable "github_token" {
  description = "GitHub token for repo creation"
  type        = string
  default     = null
}

variable "github_owner" {
  description = "GitHub organization or user for repo creation"
  type        = string
  default     = "CircleCI-Labs"
}

variable "appteam_pipeline_profiles" {
  description = "Collection on restricted contexts to manage."
  type = object({
    application_name     = string
    application_template = string
    context_name         = string
    # Provided as type:value pairs
    context_restrictions = map(string)
    # reference the value ina  sensitive set defined below, otherwise we can't loop values.
    context_variables = set(string)
    template_owner    = string
  })
  # No default - all values provided via tfvars
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