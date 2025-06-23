package org

# Policy name for CircleCI
policy_name["python_minimum_version"]

# Enable this rule for soft warnings (warnings only, builds continue)
enable_rule["python_minimum_version"]

# Minimum required Python version
minimum_python_version := "3.13.5"

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

# Helper function to extract version from image tag
extract_version(image) := version {
    # Check if image starts with cimg/python:
    startswith(image, "cimg/python:")
    
    # Extract the version part after the colon
    parts := split(image, ":")
    count(parts) == 2
    version := parts[1]
}

# Helper function to parse version string into comparable array
parse_version(version_str) := version_parts {
    parts := split(version_str, ".")
    version_parts := [to_number(part) | part := parts[_]]
}

# Helper function to compare versions
# Returns true if version1 < version2
version_less_than(version1, version2) {
    v1 := parse_version(version1)
    v2 := parse_version(version2)
    
    # Compare major version
    v1[0] < v2[0]
}

version_less_than(version1, version2) {
    v1 := parse_version(version1)
    v2 := parse_version(version2)
    
    # Same major version, compare minor
    v1[0] == v2[0]
    v1[1] < v2[1]
}

version_less_than(version1, version2) {
    v1 := parse_version(version1)
    v2 := parse_version(version2)
    
    # Same major and minor version, compare patch
    v1[0] == v2[0]
    v1[1] == v2[1]
    v1[2] < v2[2]
}

# Soft warning rule for Python versions below minimum
python_minimum_version[msg] {
    # Skip if this project is excluded
    not is_project_excluded
    
    # Check all jobs in the configuration
    some job_name
    job := input.jobs[job_name]
    
    # Check each docker image in the job
    docker_config := job.docker[_]
    
    # Extract version from cimg/python images
    python_version := extract_version(docker_config.image)
    
    # Check if version is below minimum
    version_less_than(python_version, minimum_python_version)
    
    msg := sprintf("Job '%s' uses Python version %s which is below the minimum required version %s. Please update to cimg/python:%s or higher. For help, contact the Platform team or see https://github.com/CircleCI-Labs/platform-team-configs/blob/main/policies/python-version/README.md", [job_name, python_version, minimum_python_version, minimum_python_version])
}