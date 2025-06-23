# Debug Policies

This directory contains debug versions of policies that include additional diagnostic output to help troubleshoot policy behavior.

## Purpose

Debug policies are useful for:
- Troubleshooting policy logic issues
- Understanding how input data is being parsed
- Diagnosing why policies are or aren't triggering
- Analyzing job discovery and version extraction

## Usage

### Testing Debug Policies

To test a debug policy in isolation:

```bash
# Test the debug version of the Python policy
circleci policy test policies/debug/python-minimum-version-debug.rego path/to/test-input.yaml
```

### Debug Output

Debug policies include additional rules that output diagnostic information:

- `debug_input_structure`: Shows what input sections are available
- `debug_jobs_found`: Lists discovered jobs in the configuration  
- `debug_docker_configs`: Shows Docker images found in each job
- `debug_version_extraction`: Shows version parsing results

## Important Notes

⚠️ **Debug policies should NOT be deployed to production** - they are for troubleshooting only.

⚠️ **Keep debug policies in this separate directory** - having them in the same directory as production policies will cause test failures due to rule conflicts.

## Available Debug Policies

- `python-minimum-version-debug.rego`: Debug version of the Python minimum version policy

## Example Debug Output

When running a debug policy, you'll see output like:

```
soft_failures:
  - reason: 'DEBUG: Input structure - compiled exists: true, regular jobs exist: true'
    rule: debug_input_structure
  - reason: 'DEBUG: Found compiled jobs: ["build", "test"]'
    rule: debug_jobs_found
  - reason: 'DEBUG: Job "build" docker images: ["cimg/python:3.13.4"]'
    rule: debug_docker_configs
  - reason: 'DEBUG: Job "build" image "cimg/python:3.13.4" extracted version: "3.13.4"'
    rule: debug_version_extraction
```

This helps you understand exactly how the policy is processing your configuration. 