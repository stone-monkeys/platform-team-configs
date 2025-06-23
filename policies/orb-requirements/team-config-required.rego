package org

# Policy name for CircleCI
policy_name["team_config_required"]

# Enable the individual rules
enable_rule["team_config_missing"]
enable_rule["team_config_invalid_url"]

# Required orb name
required_orb_name := "team-config"

# Excluded project IDs - these projects will be skipped by this policy
excluded_projects := {
    "e3914273-2713-4f0f-999d-f9fbd6748cf8"
}

# Helper function to check if current project should be excluded
is_project_excluded {
    # Check multiple possible locations for project ID
    project_id := input.meta.project_id
    excluded_projects[project_id]
}

is_project_excluded {
    # Alternative: check if project ID is in different location
    project_id := input.project_id
    excluded_projects[project_id]
}

is_project_excluded {
    # Alternative: check if project ID is in context
    project_id := input.context.project_id
    excluded_projects[project_id]
}

# Check if the required orb is present in the configuration
has_team_config_orb {
    # Check if orbs section exists and contains team-config
    input.orbs[required_orb_name]
}

# Check if the team-config orb URL follows the correct convention
has_valid_team_config_url {
    # Get the team-config orb URL
    orb_url := input.orbs[required_orb_name]
    
    # Check if URL ends with .circleci/team-config.yml
    endswith(orb_url, ".circleci/team-config.yml")
}

# Rule: Missing team-config orb when orbs section exists
team_config_missing[msg] {
    # Skip if this project is excluded
    not is_project_excluded
    
    # Check if orbs section exists and is not null
    input.orbs != null
    
    # But team-config orb is missing
    not has_team_config_orb
    
    msg := sprintf("Configuration should include a '%s' orb that references '.circleci/team-config.yml'. This orb provides platform-managed overrides and is recommended for all projects. For help, contact the Platform team or see https://github.com/CircleCI-Labs/platform-team-configs/blob/main/policies/orb-requirements/README.md", [required_orb_name])
}

# Rule: Invalid team-config orb URL format
team_config_invalid_url[msg] {
    # Skip if this project is excluded
    not is_project_excluded
    
    # team-config orb exists
    has_team_config_orb
    
    # But URL doesn't follow the convention
    not has_valid_team_config_url
    
    orb_url := input.orbs[required_orb_name]
    msg := sprintf("The '%s' orb URL '%s' should end with '.circleci/team-config.yml' to follow platform conventions. For help, contact the Platform team or see https://github.com/CircleCI-Labs/platform-team-configs/blob/main/policies/orb-requirements/README.md", [required_orb_name, orb_url])
} 