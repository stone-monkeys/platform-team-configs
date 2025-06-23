package org
import future.keywords


# DEBUG VERSION - Policy name for CircleCI
policy_name["python_minimum_version_debug"]

# Enable debug rules
enable_rule["debug_input_structure"]
enable_rule["debug_jobs_found"]
enable_rule["debug_jobs_found_compiled"]
enable_rule["debug_docker_configs"]
enable_rule["debug_docker_configs_compiled"]
enable_rule["debug_version_extraction"]
enable_rule["debug_version_extraction_compiled"]
enable_rule["python_minimum_version"]
enable_rule["debug_input_jobs"]

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

# Debug rule: Show input structure
debug_input_structure[msg] {
    msg := sprintf("DEBUG: Input structure - compiled exists: %v, regular jobs exist: %v", [
        input._compiled_ != null,
        input.jobs != null
    ])
}

debug_input_jobs[msg] {
    msg := sprintf("DEBUG: Input structure - raw config exists: %v, regular jobs exist: %v", [
        input != null,
        input.jobs != null
    ])
}

# Debug rule: Show what jobs are found
debug_jobs_found_compiled[msg] {
    input.compiled
    job_names := [name | input.compiled.jobs[name]]
    msg := sprintf("DEBUG COMPILED: Found compiled jobs: %v", [job_names])
}

debug_jobs_found[msg] {
    not input.compiled
    input.jobs
    job_names := [name | input.jobs[name]]
    msg := sprintf("DEBUG: Found regular jobs: %v", [job_names])
}

# Debug rule: Show docker configurations found
debug_docker_configs_compiled[msg] {
    input.compiled
    some job_name
    job := input.compiled.jobs[job_name]
    job.docker
    docker_images := [config.image | config := job.docker[_]]
    msg := sprintf("DEBUG COMPILED: Job '%s' docker images: %v", [job_name, docker_images])
}

debug_docker_configs[msg] {
    not input.compiled
    input.jobs
    some job_name
    job := input.jobs[job_name]
    job.docker
    docker_images := [config.image | config := job.docker[_]]
    msg := sprintf("DEBUG: Job '%s' docker images: %v", [job_name, docker_images])
}

# Debug rule: Show version extraction results
debug_version_extraction_compiled[msg] {
    input.compiled
    some job_name
    job := input.compiled.jobs[job_name]
    docker_config := job.docker[_]
    startswith(docker_config.image, "cimg/python:")
    python_version := extract_version(docker_config.image)
    msg := sprintf("DEBUG COMPILED: Job '%s' image '%s' extracted version: '%s'", [job_name, docker_config.image, python_version])
}

debug_version_extraction[msg] {
    not input.compiled
    input.jobs
    some job_name
    job := input.jobs[job_name]
    docker_config := job.docker[_]
    startswith(docker_config.image, "cimg/python:")
    python_version := extract_version(docker_config.image)
    msg := sprintf("DEBUG: Job '%s' image '%s' extracted version: '%s'", [job_name, docker_config.image, python_version])
}

# Soft warning rule for Python versions below minimum - check compiled jobs first
python_minimum_version[msg] {
    # Skip if this project is excluded
    not is_project_excluded
    
    # Check all jobs in the compiled configuration
    some job_name
    job := input.compiled.jobs[job_name]
    
    # Check each docker image in the job
    docker_config := job.docker[_]
    
    # Extract version from cimg/python images
    python_version := extract_version(docker_config.image)
    
    # Check if version is below minimum
    version_less_than(python_version, minimum_python_version)
    
    msg := sprintf("Job '%s' uses Python version %s which is below the minimum required version %s. Please update to cimg/python:%s or higher. For help, contact the Platform team or see https://github.com/CircleCI-Labs/platform-team-configs/blob/main/policies/python-version/README.md", [job_name, python_version, minimum_python_version, minimum_python_version])
} 