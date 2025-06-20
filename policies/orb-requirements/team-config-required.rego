package org

# Policy name for CircleCI
policy_name["team_config_required"]

# Enable this rule for all configurations
enable_rule["team_config_required"]

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

# Hard failure rule for missing team-config orb
hard_fail["team_config_required"] {
    # Skip if this project is excluded
    not is_project_excluded
    
    # Only check if orbs section exists
    input.orbs
    
    # But team-config orb is missing
    not has_team_config_orb
}

# Hard failure rule for invalid team-config orb URL
hard_fail["team_config_required"] {
    # Skip if this project is excluded
    not is_project_excluded
    
    # team-config orb exists
    has_team_config_orb
    
    # But URL doesn't follow the convention
    not has_valid_team_config_url
}

# Violation message for missing or invalid team-config orb
team_config_required := msg {
    hard_fail["team_config_required"]
    
    # Check what kind of violation this is
    not has_team_config_orb
    msg := sprintf("Configuration must include a '%s' orb that references '.circleci/team-config.yml'. This orb provides platform-managed overrides and is required for all projects. For help, contact the Platform team or see https://github.com/CircleCI-Labs/platform-team-configs/blob/main/policies/orb-requirements/README.md", [required_orb_name])
}

team_config_required := msg {
    hard_fail["team_config_required"]
    
    # team-config orb exists but URL is invalid
    has_team_config_orb
    not has_valid_team_config_url
    orb_url := input.orbs[required_orb_name]
    msg := sprintf("The '%s' orb URL '%s' must end with '.circleci/team-config.yml' to follow platform conventions. For help, contact the Platform team or see https://github.com/CircleCI-Labs/platform-team-configs/blob/main/policies/orb-requirements/README.md", [required_orb_name, orb_url])
}

# Warning for configurations without any orbs section
warnings[msg] {
    # Skip if this project is excluded
    not is_project_excluded
    
    # No orbs section at all
    not input.orbs
    
    msg := sprintf("Configuration should include an 'orbs' section with the required '%s' orb. For help, contact the Platform team or see https://github.com/CircleCI-Labs/platform-team-configs/blob/main/policies/orb-requirements/README.md", [required_orb_name])
} 