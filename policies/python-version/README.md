# Python Version Policy

This policy enforces a minimum Python version when using CircleCI's `cimg/python` Docker images.

## Policy Details

- **Package**: `org.python_version`
- **Type**: Soft warning (warnings, not violations)
- **Minimum Version**: `3.13.5`
- **Target**: Jobs using `cimg/python:*` Docker images

## How It Works

The policy:
1. Scans all jobs in a CircleCI configuration
2. Checks each Docker image used in jobs
3. For images matching `cimg/python:*`, extracts the version
4. Compares the version against the minimum required version (`3.13.5`)
5. Issues a warning if the version is below the minimum

## Examples

### ✅ Valid Configuration (No warnings)
```yaml
jobs:
  build:
    docker:
      - image: cimg/python:3.13.5  # Meets minimum
  test:
    docker:
      - image: cimg/python:3.14.0  # Above minimum
```

### ⚠️ Invalid Configuration (Warnings issued)
```yaml
jobs:
  build:
    docker:
      - image: cimg/python:3.13.4  # Below minimum - WARNING
  test:
    docker:
      - image: cimg/python:3.12.0  # Below minimum - WARNING
  deploy:
    docker:
      - image: cimg/node:20.11     # Different image - ignored
```

## Warning Message Format

```
Job 'build' uses Python version 3.13.4 which is below the minimum required version 3.13.5. 
Please update to cimg/python:3.13.5 or higher. For help, contact the Platform team or see 
https://github.com/CircleCI-Labs/platform-team-configs/blob/main/policies/python-version/README.md
```

## Testing

To test this policy locally using CircleCI's native testing framework:

1. **Install CircleCI CLI**: https://circleci.com/docs/local-cli/
2. **Run tests**:
   ```bash
   # Test just this policy
   circleci policy test ./policies/python-version
   
   # Test with verbose output
   circleci policy test ./policies/python-version --verbose
   
   # Test all policies
   circleci policy test ./policies/...
   ```

3. **Run specific test cases**:
   ```bash
   # Run only tests matching a pattern
   circleci policy test ./policies/python-version --run "python_version_too_low"
   
   # Debug test execution
   circleci policy test ./policies/python-version --debug
   ```

## Configuration

To change the minimum version requirement, update the `minimum_python_version` constant in `python-minimum-version.rego`:

```rego
# Change this value to update the minimum required version
minimum_python_version := "3.13.5"
```

## Converting to Hard Policy

To make this a hard policy that blocks builds instead of just warning:

1. Change `warnings[msg]` to `violations[msg]` in the policy file
2. Update the message to indicate the build is blocked
3. Test thoroughly before applying to production

## Version Comparison Logic

The policy uses semantic version comparison:
- Splits versions into major.minor.patch components
- Compares numerically (3.13.4 < 3.13.5)
- Handles different version formats correctly 