# CI/CD Best Practices

## For Platform Team
- Use reusable jobs and commands to keep configs DRY.
- Validate all configs with the CircleCI CLI before merging.
- Use orbs for common tasks and maintain them in the orbs/ directory.
- Document all changes and new patterns in the docs/ folder.
- Provide sensible defaults but allow for overrides.
- Regularly review and update templates for security and efficiency.

## For Developer Teams
- Inherit from the platform's config templates whenever possible.
- Only override jobs when necessary; keep customizations minimal.
- Validate your config after overrides using the CircleCI CLI.
- Do not commit secrets or sensitive data to configs.
- Follow naming conventions and keep job steps clear and concise.
- Reach out to the Platform Team for support or questions.
- Clone the repository locally to start working on your project.

- Install the CircleCI VS Code extension to:
  - Get inline config validation and linting
  - View pipelines without leaving the editor

- Your developers can then leverage the MCP Server from within the IDE:
  - Retrieves detailed failure logs from CircleCI builds
  - You can execute and test config changes directly from your development environment
  - Makes iterating on pipelines fast and efficient
  - You can find and identify flaky tests
  - You can get the latest pipeline status and build information
