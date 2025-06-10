# Contributing to Platform Team CircleCI Configs

Thank you for your interest in contributing! This repository is the source of truth for all CircleCI configuration templates, reusable jobs, and best practices used across the organization. To ensure quality and consistency, please follow these guidelines when proposing changes.

## How to Contribute

1. **Fork the Repository**
   - Create your own fork and branch for your changes.

2. **Make Your Changes**
   - Add or update config templates in `.circleci/config-templates/`.
   - For new tech stacks or use cases, create a new subfolder under `config-templates/`.
   - For custom orbs, add them under the `orbs/` directory.
   - Update or add documentation in `docs/` as needed.

3. **Validate Your Changes**
   - Always validate any CircleCI config changes using the CircleCI CLI:
     ```sh
     circleci config validate <PATH_TO_CONFIG>
     ```
   - If you add or update an orb, ensure it is syntactically correct and documented.

4. **Open a Pull Request**
   - Clearly describe your changes and the motivation behind them.
   - Reference any related issues or discussions.
   - Tag relevant reviewers from the Platform Team.

5. **Review Process**
   - A Platform Team member will review your PR for correctness, clarity, and alignment with best practices.
   - You may be asked to make changes or provide additional context.
   - Once approved, your changes will be merged.

## Best Practices
- **Keep configs DRY**: Use reusable commands, jobs, and orbs where possible.
- **Document everything**: Update `docs/` for any new patterns, overrides, or best practices.
- **Backward compatibility**: Avoid breaking changes unless necessary. Clearly document any breaking changes.
- **Security**: Do not commit secrets or sensitive information.
- **Testing**: If possible, test your config in a sandbox project before submitting.

## Need Help?
If you have questions, open an issue or reach out to the Platform Team.

Thank you for helping us build a better CI/CD platform for everyone! 