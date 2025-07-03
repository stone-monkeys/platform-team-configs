# Platform Team CircleCI Configs

Welcome to the **Platform Team's centralized repository for CircleCI configurations and automation**. This repository is the single source of truth for CI/CD best practices, reusable job definitions, guardrails, and automation for all developer teams across the organization.

## Purpose
- **Centralize**: Maintain all CircleCI config templates, reusable jobs, best practices, and automation in one place.
- **Automate**: Fully automated repository and CircleCI project creation via webhook triggers
- **Empower**: Allow developer teams to inherit, override, and extend platform-defined CI/CD pipelines via GitHub repo templates.
- **Standardize**: Ensure consistency, security, and quality across all projects while providing sensible defaults and flexibility.
- **Govern**: Enforce organizational standards and security requirements through automated config policies.
- **Own**: Enable the Platform Team to take ownership of CI/CD and automation, while still empowering developers to customize as needed.

## How It Works

The Platform Team defines and maintains **CircleCI pipeline templates** in the `config-templates/` directory that establish the overall structure, workflow, and job orchestration for different technology stacks. These templates are then integrated into **GitHub template repositories** (e.g., `python-starter-template`, `java-starter-template`) that contain complete project boilerplate, company development standards, and CircleCI configuration overrides.

### Platform Team Control vs Developer Flexibility

**Platform Team Defines:**
- Overall pipeline structure and workflow orchestration
- Required jobs and their execution order (build → test → security → deploy)
- Security scanning and deployment job implementations
- Compliance and governance requirements
- Infrastructure and environment configurations

**Developer Teams Can Override:**
- **Build jobs**: Customize build processes for their specific technology stack
- **Test jobs**: Implement their testing strategies and frameworks
- **Development-specific jobs**: Add linting, code quality, or other dev-focused tasks

**Developer Teams Cannot Override:**
- **Security jobs**: Platform-controlled security scanning and compliance checks
- **Deploy jobs**: Standardized deployment processes and infrastructure management
- **Workflow structure**: The overall pipeline flow and job dependencies

### Template Architecture

```
config-templates/           # Platform-managed pipeline templates
├── python/
│   └── config.yml         # Python pipeline structure & security/deploy jobs
├── nodejs/
│   └── config.yml         # Node.js pipeline structure & security/deploy jobs
└── java/
    └── config.yml         # Java pipeline structure & security/deploy jobs

GitHub Template Repos:     # Complete project templates
├── python-starter-template/
│   ├── .circleci/
│   │   └── config.yml     # References platform template + dev overrides
│   ├── src/               # Python boilerplate code
│   ├── tests/             # Company testing standards
│   └── requirements.txt   # Standard dependencies
└── nodejs-starter-template/
    ├── .circleci/
    │   └── config.yml     # References platform template + dev overrides
    ├── src/               # Node.js boilerplate code
    └── package.json       # Standard dependencies
```

### Config Policies & Governance

The Platform Team maintains **CircleCI Config Policies** to enforce organizational standards and security requirements across all projects. These policies are written in **OPA (Open Policy Agent) Rego** and automatically validate CircleCI configurations when pipelines are triggered.

#### **Policy Architecture**

```
policies/
├── python-version/                 # Python version enforcement
│   ├── python-minimum-version.rego     # Policy logic (OPA/Rego)
│   ├── python-minimum-version_test.yaml # Comprehensive test cases
│   └── README.md                        # Policy documentation
```

#### **Active Policies**

1. **Python Version Policy** (`python_minimum_version`)
   - **Purpose**: Enforces minimum Python version (3.13.5) for `cimg/python:*` Docker images
   - **Enforcement**: Soft warnings (builds continue but notify teams)
   - **Scope**: Only applies to Python-based projects using CircleCI convenience images

#### **Policy Management Workflow**

- **Automated Testing**: All policies include comprehensive test suites with extensive test cases
- **CI/CD Pipeline**: Dedicated pipeline (`.circleci/config-policies.yml`) for policy management
- **Path Filtering**: Only runs when `policies/` directory changes (efficient)
- **Manual Triggers**: Can be triggered from CircleCI UI for testing and deployment
- **Deployment**: Policies are automatically deployed to CircleCI on main branch merges

#### **Policy Development Process**

1. **Policy Creation**: Write Rego policy with comprehensive test coverage
2. **Local Testing**: Test policies locally using `circleci policy test`
3. **Feature Branch**: Create branch and push policy changes
4. **Automated Testing**: Pipeline runs tests and shows policy diff
5. **Review & Merge**: Code review and merge to main branch
6. **Automatic Deployment**: Policies are pushed to CircleCI organization

### Automated Project Creation

1. **IDP Trigger**: Development teams request new projects through Internal Developer Portals (Port, Cortex, Backstage, etc.)
2. **Webhook Processing**: IDP sends webhook to CircleCI with project specifications
3. **Terraform Automation**: The platform automatically:
   - Creates a new GitHub repository from the specified template repository
   - Inherits the complete project structure, boilerplate code, and override-enabled CircleCI config
   - Sets up CircleCI project and pipeline configuration
   - Configures contexts and environment variables
   - Applies project restrictions to existing contexts
4. **Policy Enforcement**: All new projects are automatically subject to organization-wide config policies
5. **Initial CI/CD Trigger**: An empty commit is automatically pushed to trigger the first CI/CD pipeline
6. **Ready to Use**: Teams receive a fully configured repository with working CI/CD pipeline that follows platform standards but allows developer customization

### Template-Based Architecture
- **Config Templates**: Platform-managed CircleCI pipeline definitions in `config-templates/`
- **GitHub Template Repositories**: Complete project templates that reference config templates and include override capabilities
- **Dynamic Configuration**: Projects are created from GitHub templates with platform-managed CI/CD configurations
- **Override Mechanism**: Developers can customize build/test jobs while maintaining platform-controlled security/deploy jobs

## Repository Structure

### This Repository (platform-team-configs)
```
orbs/
  └── platform-team.yml            # URL orb with reusable commands for automation
terraform/
  └── pipeline-terraform/          # Terraform automation for GitHub/CircleCI provisioning
      ├── main.tf                  # Main infrastructure definitions
      ├── variables.tf             # Variable definitions
      ├── outputs.tf               # Output definitions
      └── providers.tf             # Provider configurations
.circleci/
  ├── provision.yml                # Main automation pipeline (webhook-triggered)
  ├── deprovision.yml              # Separate pipeline for resource cleanup
  └── config-policies.yml          # Policy management CI/CD pipeline
policies/                          # CircleCI Config Policies (OPA/Rego)
  └── python-version/              # Python version enforcement policy
      ├── python-minimum-version.rego
      ├── python-minimum-version_test.yaml
      └── README.md
docs/
  ├── best-practices.md            # CI/CD best practices
  ├── override-examples.md         # How to override jobs in your repo
  └── ...
config-templates/                  # Platform-managed CircleCI pipeline templates
                                   # Define overall pipeline structure, security, and deployment jobs
                                   # Referenced by GitHub template repositories
README.md
CONTRIBUTING.md
POLICY-PIPELINE-SETUP.md          # Policy management setup and usage guide
```

## Key Components

### URL Orbs
This repository uses **URL orbs** instead of published registry orbs for maximum flexibility:

- **Location**: `orbs/platform-team.yml` 
- **Usage**: Referenced directly via raw GitHub URL in CircleCI configurations
- **Benefits**: 
  - No publishing process required
  - Immediate updates when changes are made (5 minitue cache of orb before new changes are picked up. Can use sha to avoid caching)
  - Full control over versioning and distribution
  - Organization-specific customization

**URL Orb Reference**: 
```yaml
orbs:
  platform-team: https://raw.githubusercontent.com/CircleCI-Labs/platform-team-configs/main/orbs/platform-team.yml
```

**Available Commands**:
- `parse-webhook-payload`: Extracts webhook JSON data into environment variables
- `build-terraform-provider-circleci`: Dynamically builds CircleCI Terraform provider
- `setup-tf-vars`: Configures Terraform variables from environment data

### Terraform Automation
- **Dynamic Provider Building**: Builds CircleCI Terraform provider from source with caching
- **Repository Creation**: Creates GitHub repositories from templates with proper configuration
- **CircleCI Integration**: Automatically sets up projects, pipelines, and triggers
- **Context Management**: Applies project restrictions to existing contexts for security
- **Environment Configuration**: Sets up all necessary environment variables and secrets

### Config Policy Management
- **Policy Development**: OPA/Rego policies with comprehensive test coverage
- **Automated Testing**: Dedicated CI/CD pipeline with JUnit integration
- **Manual Controls**: UI-triggered testing, deployment, and policy enable/disable
- **Path Filtering**: Efficient pipeline execution only when policies change
- **Governance**: Organization-wide enforcement of security and compliance standards

### Webhook-Driven Workflows
- **Provision Pipeline**: Triggered by webhooks to create new projects
- **Deprovision Pipeline**: API-triggered for resource cleanup
- **Empty Commit Trigger**: Automatically triggers initial CI/CD pipeline in new repositories

## Getting Started

### For Platform Team:

1. **Maintain URL Orbs:**
   - Update commands in `orbs/platform-team.yml`
   - Changes are immediately available (no publishing required)
   - Ensure URL is in organization's orb allow-list

2. **Manage Config Policies:**
   - Develop and maintain OPA/Rego policies in `policies/` directory
   - Write comprehensive test coverage for all policies
   - Use the dedicated policy pipeline (`.circleci/config-policies.yml`) for testing and deployment
   - Control policy enforcement via CircleCI UI parameters
   - See [POLICY-PIPELINE-SETUP.md](POLICY-PIPELINE-SETUP.md) for detailed setup and usage

3. **Manage Terraform Infrastructure:**
   - Update automation in `terraform/pipeline-terraform/`
   - Modify template repository references as needed
   - Update context and environment variable configurations

4. **Template Repository Management:**
   - Create/maintain separate template repositories: `<technology>-starter-template`
   - Ensure templates include proper `.circleci/config.yml` configurations
   - Follow naming conventions for automatic discovery

### For Developer Teams:

1. **Request New Project via IDP:**
   - Access your Internal Developer Portal (Port, Cortex, Backstage, etc.)
   - Select "Create New Project" or similar option
   - Specify project details:
     - `template_repo`: Technology stack template (e.g., `python-starter-template`)
     - `target_repo`: Name for your new repository
     - Additional project metadata as required by your IDP

2. **Automated Workflow Execution:**
   - **IDP Webhook**: Your IDP sends a webhook to CircleCI with project specifications
   - **Repository Creation**: Terraform creates a new GitHub repository using the specified template
   - **Complete Project Setup**: The new repository includes:
     - Complete boilerplate code and project structure
     - Company development standards and testing frameworks
     - CircleCI configuration with override capabilities
     - All necessary dependencies and tooling
   - **CircleCI Integration**: Project is automatically onboarded to CircleCI with proper contexts
   - **Initial Build Trigger**: An empty commit triggers the first CI/CD pipeline run

3. **Post-Creation Development:**
   - **Clone and Develop**: Clone your new repository and start developing immediately
   - **Working CI/CD**: Pipeline is ready to use with platform-managed security and deployment
   - **Customize Build/Test**: Override build and test jobs as needed for your specific requirements.
   - **Maintain Standards**: Security and deployment jobs remain platform-managed for compliance

4. **Development Workflow:**
   - **Build Customization**: Modify build processes for your technology stack
   - **Test Implementation**: Add your testing strategies and frameworks
   - **Code Quality**: Implement linting, formatting, and other development tools
   - **Platform Compliance**: Security scanning and deployment remain standardized

## URL Orb Management

### Organization Allow-List Setup
To use URL orbs, your CircleCI organization must allow the repository URL:

1. Navigate to **Organization Settings > Orbs** in CircleCI
2. Add to URL allow-list: `https://raw.githubusercontent.com/CircleCI-Labs/`
3. This allows importing orbs from this repository

### URL Orb Benefits
- **No Publishing Required**: Changes are immediately available
- **Version Control**: Use Git commits/tags for versioning
- **Organization Control**: Restrict access via allow-lists
- **Rapid Iteration**: Update and test changes without registry delays

For more information about URL orbs, see the [CircleCI URL Orb Documentation](https://circleci.com/docs/orb-intro/#use-a-url-orb).

## Automation Features

### Webhook Processing
- **JSON Parsing**: Automatically extracts webhook payload into environment variables
- **Dynamic Configuration**: Uses webhook data to configure Terraform variables
- **Error Handling**: Validates required parameters and provides clear error messages

### Infrastructure as Code
- **GitHub Repository Creation**: Creates repositories from templates with proper settings
- **CircleCI Project Setup**: Configures projects, pipelines, and triggers automatically
- **Context Security**: Applies project restrictions to limit context access
- **Environment Variables**: Sets up all necessary secrets and configuration

### CI/CD Pipeline Triggering
- **Empty Commit Strategy**: Uses shallow git clone to create empty commits
- **GitHub CLI Integration**: Leverages GitHub CLI for secure authentication
- **Automatic Triggering**: Ensures new repositories have immediate CI/CD capability

## Environment Variables

The automation requires these environment variables (configured in CircleCI contexts):

### Project Automation Context
- `GITHUB_TOKEN`: GitHub authentication token
- `CIRCLE_TOKEN`: CircleCI API token  
- `AWS_ACCOUNT_ID`: AWS account for Terraform state
- `AWS_IAM_PREFIX`: IAM role prefix for AWS authentication
- `GITHUB_ORG`: GitHub organization name

### Policy Management Context (`policy-management`)
- `CIRCLECI_CLI_TOKEN`: Personal API token for CLI authentication
- `ORG_ID`: CircleCI organization ID for policy operations

**Note**: The `policy-management` context should be restricted to authorized groups (Platform Team, DevOps) for security.

## Install the CircleCI Github App

In order to setup Centralized Config Management and the relevant triggers, we must install the CircleCI Github App - https://circleci.com/docs/github-apps-integration/

The Platform team will then need to decide how they will trigger the provisioning pipelines:
    
1. If the team is leveraging a IDP, they will configure an custom webhook in the triggers section in CircleCI. In our example you can see our custom webooks from Cortex and from Port 
2. If the team is triggering the provision and deprovision pipelines from the CircleCI UI, additional configuration will be requred to pass the correct environment variables

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on:
- Proposing changes to automation workflows
- Adding new template repositories
- Updating URL orb commands
- Testing infrastructure changes

## Support

For questions or support:
- Open an issue in this repository
- Contact the Platform Team
- Check the [CircleCI Documentation](https://circleci.com/docs/) for general CircleCI questions
