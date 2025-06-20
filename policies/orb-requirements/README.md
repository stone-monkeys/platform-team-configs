# Team-Config Orb Requirement Policy

This policy enforces that all CircleCI configurations include a `team-config` orb with the correct URL format, which provides platform-managed overrides and standardized functionality.

## Policy Details

- **Package**: `org`
- **Policy Name**: `team_config_required`
- **Type**: Hard violation (blocks builds) + Soft warning (for missing orbs section)
- **Required Orb**: `team-config`
- **Required URL Format**: Must end with `.circleci/team-config.yml`
- **Target**: All CircleCI configurations

## How It Works

The policy:
1. Scans the `orbs` section of CircleCI configurations
2. **Hard Violation**: If `orbs` section exists but `team-config` orb is missing
3. **Hard Violation**: If `team-config` orb exists but URL doesn't end with `.circleci/team-config.yml`
4. **Soft Warning**: If no `orbs` section exists at all
5. **Pass**: If `team-config` orb is present with correct URL format

## Enforcement Levels

### 🚫 **Hard Violation (Blocks Build)**
- Configuration has `orbs` section but missing `team-config`
- Empty `orbs` section (`orbs: {}`)
- `team-config` orb present but URL doesn't end with `.circleci/team-config.yml`

### ⚠️ **Soft Warning (Build Continues)**
- No `orbs` section in configuration

### ✅ **Pass**
- `team-config` orb is present with correct URL format

## Examples

### ✅ Valid Configurations

**Minimal with team-config:**
```yaml
version: 2.1
orbs:
  team-config: "https://raw.githubusercontent.com/my-org/my-repo/main/.circleci/team-config.yml"
jobs:
  build:
    docker:
      - image: cimg/base:stable
```

**With multiple orbs:**
```yaml
version: 2.1
orbs:
  team-config: "https://raw.githubusercontent.com/my-org/my-repo/main/.circleci/team-config.yml"
  docker: circleci/docker@2.8.2
  python: circleci/python@3.1.0
jobs:
  build:
    docker:
      - image: cimg/python:3.13.5
```

### 🚫 Invalid Configurations (Hard Fail)

**Missing team-config orb:**
```yaml
version: 2.1
orbs:
  docker: circleci/docker@2.8.2
  python: circleci/python@3.1.0  # Missing team-config - HARD FAIL
```

**Empty orbs section:**
```yaml
version: 2.1
orbs: {}  # Empty orbs section - HARD FAIL
```

**Wrong URL format:**
```yaml
version: 2.1
orbs:
  team-config: "https://example.com/wrong-path/config.yml"  # Wrong URL format - HARD FAIL
```

### ⚠️ Warning Configuration (Soft Warning)

**No orbs section:**
```yaml
version: 2.1
jobs:
  build:
    docker:
      - image: cimg/base:stable
# No orbs section - WARNING
```

## Message Formats

### Hard Violation Messages

**Missing team-config orb:**
```
Configuration must include a 'team-config' orb that references '.circleci/team-config.yml'. 
This orb provides platform-managed overrides and is required for all projects. For help, 
contact the Platform team or see 
https://github.com/CircleCI-Labs/platform-team-configs/blob/main/policies/orb-requirements/README.md
```

**Invalid URL format:**
```
The 'team-config' orb URL 'https://example.com/wrong-path/config.yml' must end with 
'.circleci/team-config.yml' to follow platform conventions. For help, contact the Platform 
team or see 
https://github.com/CircleCI-Labs/platform-team-configs/blob/main/policies/orb-requirements/README.md
```

### Warning Message
```
Configuration should include an 'orbs' section with the required 'team-config' orb. 
For help, contact the Platform team or see 
https://github.com/CircleCI-Labs/platform-team-configs/blob/main/policies/orb-requirements/README.md
```

## Testing

To test this policy locally using CircleCI's native testing framework:

1. **Install CircleCI CLI**: https://circleci.com/docs/local-cli/
2. **Run tests**:
   ```bash
   # Test just this policy
   circleci policy test ./policies/orb-requirements
   
   # Test with verbose output
   circleci policy test ./policies/orb-requirements --verbose
   
   # Test all policies
   circleci policy test ./policies/...
   ```

3. **Run specific test cases**:
   ```bash
   # Run only tests matching a pattern
   circleci policy test ./policies/orb-requirements --run "missing_team_config_orb"
   
   # Debug test execution
   circleci policy test ./policies/orb-requirements --debug
   ```

## Configuration

To change the required orb name, update the `required_orb_name` constant in `team-config-required.rego`:

```rego
# Change this value to update the required orb name
required_orb_name := "team-config"
```

## Why This Policy Exists

The `team-config` orb is essential because it:

- **Provides Overrides**: Allows teams to customize build/test jobs while maintaining platform standards
- **Enables Governance**: Platform team controls security and deployment jobs
- **Ensures Consistency**: Standardizes common functionality across all projects
- **Facilitates Updates**: Platform can update shared functionality centrally

## Integration with Platform Architecture

This policy works with your existing platform setup:

- **Config Templates**: Platform templates already include `team-config` orb
- **URL Orbs**: Teams reference their own `team-config.yml` via URL orbs
- **Override Mechanism**: Teams can override specific jobs while maintaining platform compliance

## Converting to Soft Warning

To make this a soft warning policy instead of hard violation:

1. Change `violations[msg]` to `warnings[msg]` in the policy file
2. Update tests to expect `status: PASS` instead of `status: HARD_FAIL`
3. Test thoroughly before applying to production

## Troubleshooting

**Common Issues:**

1. **Missing orb reference**: Add `team-config` to your `orbs` section
2. **Wrong orb name**: Ensure the orb is named exactly `team-config`
3. **Wrong URL format**: Ensure the URL ends with `.circleci/team-config.yml`
4. **Empty orbs section**: Add your `team-config` orb reference

**Need Help?**
- Contact the Platform team
- Review your organization's config templates
- Check existing working configurations for examples 