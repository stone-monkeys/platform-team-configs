package org

# Policy name for CircleCI
policy_name["team_config_required"]

# Enable this rule for all configurations
enable_rule["team_config_required"]

# Required orb name
required_orb_name := "team-config"

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
    # Only check if orbs section exists
    input.orbs
    
    # But team-config orb is missing
    not has_team_config_orb
}

# Hard failure rule for invalid team-config orb URL
hard_fail["team_config_required"] {
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
    # No orbs section at all
    not input.orbs
    
    msg := sprintf("Configuration should include an 'orbs' section with the required '%s' orb. For help, contact the Platform team or see https://github.com/CircleCI-Labs/platform-team-configs/blob/main/policies/orb-requirements/README.md", [required_orb_name])
} 