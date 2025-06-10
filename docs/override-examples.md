# Overriding Platform CI/CD Jobs: Examples

The Platform Team provides base CircleCI configs with sensible defaults. You can override or extend jobs in your own repository as needed.

## Example: Overriding the `test` Job

Suppose the platform config defines a `test` job. To override it in your repo:

```yaml
# .circleci/config.yml in your repo
version: 2.1

workflows:
  version: 2
  my_custom_ci:
    jobs:
      - checkout
      - test
      - deploy

jobs:
  test:
    docker:
      - image: cimg/node:lts
    steps:
      - run: npm run custom-test

  deploy:
    docker:
      - image: cimg/node:lts
    steps:
      - run: echo "Custom deploy logic..."
```

## Example: Adding a New Job

You can add new jobs to your workflow as needed:

```yaml
jobs:
  security-scan:
    docker:
      - image: cimg/base:stable
    steps:
      - run: echo "Running security scan..."

workflows:
  version: 2
  my_custom_ci:
    jobs:
      - checkout
      - test
      - security-scan
      - deploy
```

## Tips
- Only override jobs you need to customize.
- Keep overrides minimal to benefit from platform updates.
- Always validate your config after making changes. 