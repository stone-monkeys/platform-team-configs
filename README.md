# Platform Team CircleCI Configs

Welcome to the **Platform Team's centralized repository for CircleCI configurations and automation**. This repository is the single source of truth for CI/CD best practices, reusable job definitions, guardrails, and automation for all developer teams across the organization.

## Purpose
- **Centralize**: Maintain all CircleCI config templates, reusable jobs, best practices, and automation in one place.
- **Empower**: Allow developer teams to inherit, override, and extend platform-defined CI/CD pipelines via GitHub repo templates.
- **Standardize**: Ensure consistency, security, and quality across all projects while providing sensible defaults and flexibility.
- **Own**: Enable the Platform Team to take ownership of CI/CD and automation, while still empowering developers to customize as needed.

## How It Works
- The Platform Team defines and maintains CircleCI config templates as **separate template repositories** (e.g., `python-starter-template`, `java-starter-template`), along with reusable orbs and automation scripts in this repo.
- Developer teams request new projects via the automated pipeline, which clones the appropriate template repository and creates a new project with that template's structure and best practices.
- The automation handles both GitHub repository creation and CircleCI project setup, ensuring consistent configuration across all projects.
- Developers can customize and extend their projects after creation, while maintaining the core structure and guardrails from the template.

## Repository Structure

### This Repository (platform-team-configs)
```
orbs/
  └── <orb-name>/              # Custom orbs maintained by the platform team
      ├── orb.yml
      └── ...
terraform/
  └── pipeline-terraform/      # Terraform automation for creating repos/projects on GH and CircleCI
.circleci/
  └── config.yml               # CI/CD pipeline for project creation automation
  └── terraform_provider/      # Terraform provider and configuration templates
docs/
  ├── best-practices.md        # CI/CD best practices
  ├── override-examples.md     # How to override jobs in your repo
  └── ...
config-templates/              # Legacy: Being migrated to separate repositories
README.md
CONTRIBUTING.md
```

### Template Repositories (Separate Repos)
Template repositories are maintained as individual repositories with naming convention:
```
python-starter-template/       # Python project template
  ├── .circleci/
  │   └── config.yml
  ├── src/
  ├── tests/
  ├── requirements.txt
  └── README.md

java-starter-template/         # Java project template  
  ├── .circleci/
  │   └── config.yml
  ├── src/
  ├── pom.xml
  └── README.md

nodejs-starter-template/       # Node.js project template
  ├── .circleci/
  │   └── config.yml
  ├── src/
  ├── package.json
  └── README.md
```

- **orbs/**: Custom orbs maintained by the platform team for common tasks.
- **terraform/**: Automation scripts for creating new repositories/projects on GitHub and CircleCI.
- **.circleci/**: Contains the CI/CD pipeline for running project creation automation.
- **docs/**: Documentation, best practices, and override guides.
- **Template Repositories**: Individual repositories containing complete project templates for different tech stacks.

## Getting Started

### For Platform Team:
1. **Create/Update Template Repositories:**
   - Create new template repositories following the naming convention: `<technology>-starter-template`
   - Include complete project structure with `.circleci/config.yml`, source code, and documentation
   - Ensure templates follow best practices and include necessary dependencies

2. **Maintain This Repository:**
   - Maintain orbs in the `orbs/` directory
   - Update Terraform automation in the `terraform/` directory  
   - Update documentation in `docs/` as needed
   - Keep the project creation pipeline up-to-date

### For Developer Teams:
1. **Request New Project:**
   - Trigger the automation pipeline via API with:
     - `template_repo`: Name of template repository (e.g., `python-starter-template`)
     - `target_repo`: Name for your new repository
   
2. **Example API Call:**
   ```json
   {
     "parameters": {
       "template_repo": "python-starter-template",
       "target_repo": "my-awesome-python-app"
     }
   }
   ```

3. **After Project Creation:**
   - Clone your new repository and start developing
   - Customize the CI/CD pipeline as needed
   - Follow best practices documented in `docs/`

## Contributing
See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on proposing changes, adding new templates, or updating documentation.

## Support
For questions or support, please open an issue or contact the Platform Team.
