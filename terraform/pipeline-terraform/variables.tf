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
  default     = "stone-monkeys"
}

variable "appteam_pipeline_profiles" {
  description = "Collection on restricted contexts to manage."
  type = object({
    application_name     = string
    application_template = optional(string, null)
    context_name         = optional(string, null)
    # Provided as type:value pairs
    context_restrictions = optional(map(string), {})
    # reference the value in a sensitive set defined below, otherwise we can't loop values.
    context_variables    = optional(set(string), [])
    template_owner       = optional(string, null)
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