# StackClass Infrastructure Kubernetes Management

This repository contains the Helmfile and Kubernetes configurations for
deploying the StackClass platform, including its core services and dependencies.
The charts used come from [the helm charts
repository](https://github.com/stackclass/charts) and external providers.

## Prerequisites

Before deploying, ensure you have the following tools installed:

- `kubectl` - configured to access your Kubernetes cluster.
- `helm` - package manager for Kubernetes applications.
- `helmfile` - declarative spec for deploying Helm charts.
- `yq` - YAML processor for command-line operations. (optional)
- `jq` - Lightweight command-line JSON processor. (optional)

## Installation

1. **Clone the repository**:

   ```bash
   git clone https://github.com/stackclass/infra.git
   cd infra
   ```

2. **Initialize Helmfile**:

   ```bash
   helmfile init
   ```

   This will install the required plugins and set up the Helmfile environment.

## Configuration

Helmfile uses **environments** (such as `development` and `production`) to
manage deployments for different environments. These environments are specified
using the `--environments` flag when running `helmfile apply` or `sync`.

### Customizing Values

To configure services for your deployment, edit the YAML files in the `values/`
directory. Key files include:

- `values/global.yaml`: Controls which services are enabled globally. -
  Service-specific files like `values/gitea/values.yaml`: Configure settings for
  individual services.

For environment-specific overrides, edit the corresponding files under
`values/<service>/{{ .Environment.Name }}.yaml`. For example:
- `values/cert-manager/development.yaml` for the `development` profile.
- `values/cert-manager/production.yaml` for the `production` profile.

## Usage

### Full Installation / Uninstallation

1. **Install all services for an environment** (e.g., `development` or `production`):
   This will sync all releases defined in `helmfile.yaml` for the specified
   environment.

   ```bash
   just install development  # or `just install production`
   ```

2. **Uninstall all services for an environment**:
   This will destroy all releases for the specified environment.

   ```bash
   just uninstall development  # or `just uninstall production`
   ```

### Tier-Based Operations

Use the `tier` and `environment` **positional arguments** to target specific
tiers (`common`, `deps`, or `app`) for granular control.

1. **Apply changes for a tier** (e.g., `common` infrastructure components): This
will apply changes (create/update) for the specified tier in the given
environment.

   ```bash
   just apply common development  # tier=common, environment=development
   ```

2. **Sync a tier** (e.g., `deps` dependencies):
   This will synchronize the state of the specified tier in the given
   environment.

   ```bash
   just sync deps production  # tier=deps, environment=production
   ```

3. **Destroy a tier** (e.g., `app` main application):
   This will uninstall all releases in the specified tier for the given
   environment.

   ```bash
   just destroy app development  # tier=app, environment=development
   ```

### Additional Commands

- **Dry Run**:
  Preview changes for a tier without applying them:

  ```bash
  helmfile --environment <env> --selector tier=<tier> apply --dry-run
  ```

###

## Development

### Fetching Default Values

This task is intended for maintainers to fetch the default values of Helm
charts. It should be run whenever the Helm chart versions are updated in
`helmfile.yaml`.

```bash
just fetch-default-values
```

### Linting

Run linting to validate configurations:
```bash
just lint
```

### CI/CD

The repository includes a GitHub Actions workflow (`ci.yml`) for linting and
validation on pull requests and pushes.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.

## License

Copyright (c) The StackClass Authors. All rights reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

      https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
