# CircleCI Config Policies

This directory contains Open Policy Agent (OPA) policies written in Rego that enforce organizational standards for CircleCI configurations.

## Policy Structure

- `python-version/` - Policies related to Python Docker image versions
- `orb-requirements/` - Policies for required orbs and orb usage
- `security/` - Security-related policies
- `resources/` - Resource usage and limits policies

## Policy Types

- **Hard policies**: Block builds that violate rules (violations)
- **Soft policies**: Generate warnings but allow builds to proceed (warnings)
- **Decision policies**: Control which policies are applied to which projects

## Testing Policies

Use CircleCI's native policy testing framework:

```bash
# Test all policies
circleci policy test ./policies/...

# Test a specific policy directory
circleci policy test ./policies/python-version

# Test with verbose output to see individual test cases
circleci policy test ./policies/python-version --verbose

# Run specific test cases
circleci policy test ./policies/python-version --run "python_version_too_low"

# Debug test execution
circleci policy test ./policies/python-version --debug
```

## Applying Policies

Policies are applied through the CircleCI web interface:
1. Go to Organization Settings → Policies
2. Upload policy files or directories
3. Configure enforcement levels (hard/soft)
4. Monitor policy violations in builds

## Policy Development

When developing new policies:
1. Write the policy in Rego
2. Create test cases with sample configurations
3. Test locally with OPA CLI
4. Start with soft enforcement
5. Monitor and adjust before making hard enforcement 