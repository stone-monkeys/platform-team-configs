# Team-Config Orb Requirement Policy

This policy enforces that CircleCI configurations using orbs include a `team-config` orb with the correct URL format. The policy provides platform-managed overrides and standardized functionality for teams already using orbs.

## Policy Details

- **Package**: `org`
- **Policy Name**: `team_config_required`
- **Type**: Soft warning (build continues with warnings)
- **Required Orb**: `team-config`
- **Required URL Format**: Must end with `.circleci/team-config.yml`
- **Scope**: Only configurations that already use orbs
- **Enabled Rules**: `team_config_missing`, `team_config_invalid_url`

## What the Policy DOES Cover ✅

**Scope:** Only checks CircleCI configurations that already use orbs (has an `orbs:` section)

**Enforcement:**
1. **Missing team-config orb** - Warns when a configuration has orbs but is missing the required `team-config` orb
2. **Invalid URL format** - Warns when the `team-config` orb exists but the URL doesn't end with `.circleci/team-config.yml`

**Policy Behavior:**
- **Soft warnings only** - Builds continue, but warnings are displayed
- **Project exclusion** - Skips enforcement for excluded project ID: `e3914273-2713-4f0f-999d-f9fbd6748cf8`
- **Helpful messaging** - Provides contact information and documentation links in warning messages

## What the Policy DOES NOT Cover ❌

**Out of Scope:**
1. **Configurations without orbs** - If a project has no `orbs:` section at all, the policy ignores it completely
2. **Hard enforcement** - Policy never blocks/fails builds, only provides warnings
3. **URL content validation** - Doesn't check if the URL actually exists or contains valid configuration
4. **Orb version requirements** - Doesn't enforce specific versions of the team-config orb
5. **Other orb requirements** - Only focuses on the `team-config` orb, ignores other orbs

## How It Works

The policy:
1. Scans configurations for an `orbs` section
2. **Ignores** configurations with no `orbs` section (they pass automatically)
3. **Soft Warning**: If `orbs` section exists but `team-config` orb is missing
4. **Soft Warning**: If `team-config` orb exists but URL doesn't end with `.circleci/team-config.yml`
5. **Pass**: If `team-config` orb is present with correct URL format

## Enforcement Levels

### ⚠️ **Soft Warning (Build Continues)**
- Configuration has `orbs` section but missing `team-config`
- Empty `orbs` section (`orbs: {}`)
- `team-config` orb present but URL doesn't end with `.circleci/team-config.yml`

### ✅ **Pass**
- `team-config` orb is present with correct URL format
- **No `orbs` section at all** (policy doesn't apply)

### 🚫 **Excluded**
- Project ID: `e3914273-2713-4f0f-999d-f9fbd6748cf8` (policy skipped entirely)

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

**No orbs section (policy doesn't apply):**
```yaml
version: 2.1
jobs:
  build:
    docker:
      - image: cimg/base:stable
# No orbs section - PASSES (policy doesn't apply)
```

### ⚠️ Warning Configurations (Soft Warning)

**Missing team-config orb:**
```yaml
version: 2.1
orbs:
  docker: circleci/docker@2.8.2
  python: circleci/python@3.1.0  # Missing team-config - WARNING
```

**Empty orbs section:**
```yaml
version: 2.1
orbs: {}  # Empty orbs section - WARNING
```

**Wrong URL format:**
```yaml
version: 2.1
orbs:
  team-config: "https://example.com/wrong-path/config.yml"  # Wrong URL format - WARNING
```

## Message Formats

### Warning Messages

**Missing team-config orb:**
```
Configuration should include a 'team-config' orb that references '.circleci/team-config.yml'. 
This orb provides platform-managed overrides and is recommended for all projects. For help, 
contact the Platform team or see 
https://github.com/CircleCI-Labs/platform-team-configs/blob/main/policies/orb-requirements/README.md
```

**Invalid URL format:**
```
The 'team-config' orb URL 'https://example.com/wrong-path/config.yml' should end with 
'.circleci/team-config.yml' to follow platform conventions. For help, contact the Platform 
team or see 
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

3. **Current test coverage**: 9/9 tests passing
   - Valid configurations with correct team-config orb
   - Missing team-config orb scenarios
   - Invalid URL format scenarios
   - Empty orbs sections
   - Excluded project scenarios

## Configuration

### Project Exclusions

To exclude additional projects from this policy, update the `excluded_projects` set in `team-config-required.rego`:

```rego
# Add project IDs that should be excluded from this policy
excluded_projects := {
    "e3914273-2713-4f0f-999d-f9fbd6748cf8",
    "your-project-id-here"
}
```

### Required Orb Name

To change the required orb name, update the `required_orb_name` constant:

```rego
# Change this value to update the required orb name
required_orb_name := "team-config"
```

## Design Philosophy

This policy follows a **pragmatic approach**:

- **Non-intrusive** - Doesn't force teams to add orbs if they don't need them
- **Guidance-focused** - Provides warnings and guidance rather than blocking builds
- **Practical scope** - Only enforces the rule where it makes sense (when orbs are already being used)

This balances platform governance with team autonomy - it ensures teams using orbs follow platform conventions without forcing orb adoption on teams that don't need them.

## Why This Policy Exists

The `team-config` orb is essential for teams using orbs because it:

- **Provides Overrides**: Allows teams to customize build/test jobs while maintaining platform standards
- **Enables Governance**: Platform team controls security and deployment jobs
- **Ensures Consistency**: Standardizes common functionality across all projects
- **Facilitates Updates**: Platform can update shared functionality centrally

## Integration with Platform Architecture

This policy works with your existing platform setup:

- **Config Templates**: Platform templates already include `team-config` orb
- **URL Orbs**: Teams reference their own `team-config.yml` via URL orbs
- **Override Mechanism**: Teams can override specific jobs while maintaining platform compliance

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