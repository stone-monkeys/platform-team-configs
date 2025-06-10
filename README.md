# Platform Team CircleCI Configs

Welcome to the **Platform Team's centralized repository for CircleCI configurations**. This repository is the single source of truth for CI/CD best practices, reusable job definitions, and guardrails for all developer teams across the organization.

## Purpose
- **Centralize**: Maintain all CircleCI config templates, reusable jobs, and best practices in one place.
- **Empower**: Allow developer teams to inherit, override, and extend platform-defined CI/CD pipelines via GitHub repo templates.
- **Standardize**: Ensure consistency, security, and quality across all projects while providing sensible defaults and flexibility.
- **Own**: Enable the Platform Team to take ownership of CI/CD, while still empowering developers to customize as needed.

## How It Works
- The Platform Team defines and maintains CircleCI config templates, reusable jobs, and orbs in this repo.
- Developer teams use GitHub repo templates that reference these configs, inheriting the platform's structure and best practices.
- Developers can override or extend specific jobs as needed in their own repositories, while the core structure and guardrails remain enforced.

## Repository Structure

```
.circleci/
  └── config-templates/
      ├── base/
      │   └── config.yml           # The base config with required jobs and workflows
      ├── nodejs/
      │   └── config.yml           # Node.js-specific config
      ├── python/
      │   └── config.yml           # Python-specific config
      ├── docker/
      │   └── config.yml           # Dockerized app config
      └── ...                      # More tech stacks/use cases
orbs/
  └── <orb-name>/                 # Custom orbs maintained by the platform team
      ├── orb.yml
      └── ...
docs/
  ├── best-practices.md           # CI/CD best practices
  ├── override-examples.md        # How to override jobs in your repo
  └── ...
README.md
CONTRIBUTING.md
```

- **.circleci/config-templates/**: Houses all reusable CircleCI config templates for different stacks and use cases.
- **orbs/**: Custom orbs maintained by the platform team for common tasks.
- **docs/**: Documentation, best practices, and override guides.

## Getting Started
1. **For Platform Team:**
   - Add or update config templates in `.circleci/config-templates/`.
   - Maintain orbs in the `orbs/` directory.
   - Update documentation in `docs/` as needed.
2. **For Developer Teams:**
   - Use the GitHub repo template provided by the Platform Team.
   - Reference the appropriate config template from this repo.
   - Override jobs as needed (see `docs/override-examples.md`).

## Contributing
See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on proposing changes, adding new templates, or updating documentation.

## Support
For questions or support, please open an issue or contact the Platform Team.
