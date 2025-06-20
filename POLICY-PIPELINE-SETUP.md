# Policy Management CI/CD Pipeline Setup

This guide explains how to set up and use the automated CI/CD pipeline for managing CircleCI config policies.

## 🏗️ Architecture Overview

The pipeline uses **path filtering** to only run when the `policies/` directory changes, making it efficient and focused. It includes:

1. **Path Filtering**: Triggers policy workflow only when `policies/` folder changes
2. **Policy Listing**: Captures current active policies as artifacts
3. **Policy Testing**: Runs comprehensive tests with JUnit output
4. **Policy Diff**: Shows changes on feature branches (non-main)
5. **Policy Deployment**: Pushes policies to CircleCI on main branch
6. **Manual Triggers**: Can be triggered from CircleCI UI with custom parameters
7. **Policy Management**: Enable/disable policy evaluation for organization

## 🔧 Prerequisites Setup

### 1. Create Context for Policy Management

You need to create a CircleCI context named `policy-management` with the required environment variables.

**Steps:**
1. Go to CircleCI web app → **Organization Settings** → **Contexts**
2. Click **Create Context** 
3. Name it: `policy-management`
4. Add the following environment variables:

| Variable Name | Value | Description |
|--------------|-------|-------------|
| `CIRCLECI_CLI_TOKEN` | `your-personal-api-token` | Personal API token for CLI authentication |
| `ORG_ID` | `your-organization-id` | Your CircleCI organization ID |

**Finding Your Organization ID:**
- In CircleCI web app, go to **Organization Settings**
- Your Org ID is displayed at the top of the page

**Creating a Personal API Token:**
- Go to **User Settings** → **Personal API Tokens**
- Click **Create New Token**
- Copy the token value (you won't see it again!)

### 2. Context Security (Recommended)

Restrict the `policy-management` context to specific groups:
1. In the context settings, click **Add Security Group**
2. Select groups that should manage policies (e.g., Platform Team, DevOps)
3. This ensures only authorized users can deploy policies

## 📁 Pipeline Configuration

The pipeline is defined in `.circleci/config-policies.yml` and includes:

### **Workflows:**

#### `setup-workflow` (Always runs)
- Uses path filtering to detect changes in `policies/` directory
- Triggers `policy-workflow` only when policies are modified

#### `policy-workflow` (Conditional)
- **All Branches**: Lists current policies → Tests policies
- **Feature Branches**: Also shows policy diff (what would change)
- **Main Branch**: Also deploys policies to CircleCI
- **Manual Trigger**: Can be triggered from UI with `run-policy-workflow: true`

#### `test-only-workflow` (Manual trigger)
- **Purpose**: Test policies without deploying (safe for experimentation)
- **Trigger**: Set `test-only: true` in CircleCI UI
- **Actions**: Lists current policies → Tests policies → Shows diff
- **No Deployment**: Skips policy push and enable/disable operations

### **Jobs:**

#### `list-current-policies`
- **Purpose**: Capture current state before changes
- **Artifacts**: Current policy settings and bundle details
- **Commands**: `circleci policy settings`, `circleci policy fetch`

#### `test-policies`
- **Purpose**: Validate all policies with comprehensive testing
- **Test Formats**: Verbose output, JUnit XML, JSON summary
- **Artifacts**: Test results stored as CircleCI test results + artifacts
- **Commands**: `circleci policy test ./policies/... --verbose --format=junit --format=json`

#### `diff-policy-bundle` (Feature branches only)
- **Purpose**: Show what changes would be made
- **Artifacts**: Policy diff output
- **Commands**: `circleci policy diff ./policies`

#### `push-policy-bundle` (Main branch only)
- **Purpose**: Deploy policies to CircleCI organization
- **Artifacts**: Push results, updated policy bundle, settings
- **Commands**: `circleci policy push ./policies --no-prompt`

#### `enable-disable-policies` (Manual trigger)
- **Purpose**: Enable or disable policy evaluation for the organization
- **Trigger**: Set `enable-config-policies: true/false` in CircleCI UI
- **Artifacts**: Policy settings results
- **Commands**: `circleci policy settings --enabled=true/false`

## 🚀 Usage

### **Manual Pipeline Triggers**

You can trigger the pipeline manually from the CircleCI UI with different parameters:

#### **🧪 Test Only Mode**
Perfect for testing policy changes without deploying:

1. Go to CircleCI web app → Your project → **Trigger Pipeline**
2. Set parameters:
   ```json
   {
     "run-policy-workflow": true,
     "test-only": true
   }
   ```
3. **Result**: Runs tests and shows diff, but skips deployment

#### **🚀 Full Policy Deployment**
Deploy policies manually (alternative to pushing to main):

1. Go to CircleCI web app → Your project → **Trigger Pipeline**
2. Set parameters:
   ```json
   {
     "run-policy-workflow": true
   }
   ```
3. **Result**: Full workflow with deployment (if on main branch)

#### **⚙️ Enable/Disable Policy Evaluation**
Control whether policies are enforced organization-wide:

**To Enable Policies:**
```json
{
  "run-policy-workflow": true,
  "enable-config-policies": true
}
```

**To Disable Policies:**
```json
{
  "run-policy-workflow": true,
  "enable-config-policies": false
}
```

### **Making Policy Changes**

1. **Create Feature Branch**:
   ```bash
   git checkout -b feature/update-python-policy
   ```

2. **Modify Policies**:
   - Edit files in `policies/` directory
   - Add/modify `.rego` files
   - Update corresponding `_test.yaml` files

3. **Push Changes**:
   ```bash
   git add policies/
   git commit -m "Update Python version policy to 3.13.6"
   git push origin feature/update-python-policy
   ```

4. **Review Pipeline Results**:
   - Pipeline runs automatically (only for policy changes)
   - Check test results in CircleCI web app
   - Review policy diff in artifacts
   - Ensure all tests pass

5. **Merge to Main**:
   ```bash
   # Create PR and merge to main
   git checkout main
   git pull origin main
   ```

6. **Automatic Deployment**:
   - Pipeline deploys policies to CircleCI automatically
   - Check deployment artifacts for confirmation

### **Pipeline Behavior**

| Trigger Type | Parameters | Actions |
|-------------|------------|---------|
| **Auto (Feature Branch)** | Changes to `policies/` | List → Test → Diff (show changes) |
| **Auto (Main Branch)** | Changes to `policies/` | List → Test → Deploy (push to CircleCI) |
| **Manual (Test Only)** | `test-only: true` | List → Test → Diff (no deployment) |
| **Manual (Full Deploy)** | `run-policy-workflow: true` | List → Test → Deploy (if main branch) |
| **Manual (Enable Policies)** | `enable-config-policies: true` | List → Test → Enable policy evaluation |
| **Manual (Disable Policies)** | `enable-config-policies: false` | List → Test → Disable policy evaluation |
| **Any Branch** | Changes outside `policies/` | No pipeline runs (efficient!) |

## 📊 Monitoring and Artifacts

### **Test Results**
- **Location**: CircleCI Tests tab
- **Format**: JUnit XML for integration with CircleCI UI
- **Details**: Pass/fail status, test duration, error messages

### **Artifacts Available**

#### **Current State** (`list-current-policies`)
- `current-policy-settings.json` - Policy evaluation settings  
- `current-policy-bundle.json` - Complete policy bundle

#### **Test Results** (`test-policies`)
- `test-results/policy-test-results.xml` - JUnit format
- `test-results/policy-test-summary.json` - JSON summary

#### **Change Preview** (`diff-policy-bundle` - feature branches)
- `policy-diff.txt` - Shows what changes would be made

#### **Deployment Results** (`push-policy-bundle` - main branch)
- `deployment/push-results.json` - Push operation results
- `deployment/updated-policy-bundle.json` - Updated bundle status
- `deployment/updated-policy-settings.json` - Updated policy settings

#### **Policy Management Results** (`enable-disable-policies` - manual trigger)
- `policy-settings/enable-policies-result.json` - Enable operation results
- `policy-settings/disable-policies-result.json` - Disable operation results

## 🔍 Troubleshooting

### **Common Issues**

#### **Context Not Found Error**
```
ERROR: Context policy-management does not exist
```
**Solution**: Create the `policy-management` context with required variables (see Prerequisites)

#### **Authentication Error**
```
ERROR: Unable to authenticate with CircleCI API
```
**Solution**: Check `CIRCLECI_CLI_TOKEN` in context is valid and not expired

#### **Organization ID Error**
```
ERROR: Organization not found
```
**Solution**: Verify `ORG_ID` in context matches your organization ID

#### **Policy Test Failures**
```
ERROR: Policy tests failed
```
**Solution**: 
1. Check test output in CircleCI
2. Run tests locally: `circleci policy test ./policies/... --verbose`
3. Fix policy or test issues
4. Commit and push again

#### **Path Filtering Not Working**
**Issue**: Pipeline runs on every commit, not just policy changes  
**Solution**: 
1. Ensure you're using the correct config file (`.circleci/config-policies.yml`)
2. Check the `mapping` in path-filtering configuration
3. Verify `base-revision` is set correctly (usually `main`)

### **Local Testing**

Before pushing changes, test locally:

```bash
# Test all policies
circleci policy test ./policies/... --verbose

# Test with JUnit output
circleci policy test ./policies/... --format=junit

# Show what would be deployed
circleci policy diff ./policies --owner-id YOUR_ORG_ID

# Fetch current policy bundle
circleci policy fetch --owner-id YOUR_ORG_ID

# Check current policy settings
circleci policy settings --owner-id YOUR_ORG_ID

# Validate the pipeline config
circleci config validate .circleci/config-policies.yml
```

## 🔐 Security Best Practices

1. **Context Restrictions**: Limit `policy-management` context to authorized groups
2. **Token Management**: Use dedicated service account tokens, not personal tokens
3. **Branch Protection**: Require PR reviews for main branch
4. **Audit Trail**: All policy changes are tracked in git history + CircleCI artifacts
5. **Testing**: Never deploy untested policies (enforced by pipeline)

## 📚 Additional Resources

- [CircleCI Config Policies Documentation](https://circleci.com/docs/create-and-manage-config-policies/)
- [CircleCI CLI Policy Commands](https://circleci-public.github.io/circleci-cli/circleci_policy.html)
- [Path Filtering Orb](https://circleci.com/developer/orbs/orb/circleci/path-filtering)
- [CircleCI Contexts](https://circleci.com/docs/contexts/)

## 🎯 Next Steps

1. **Set up the context** with required environment variables
2. **Test the pipeline** by making a small policy change
3. **Configure branch protection** for the main branch
4. **Train your team** on the policy development workflow
5. **Monitor policy compliance** across your organization

---

**Need Help?** Contact the Platform team or create an issue in this repository. 