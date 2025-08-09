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

### Deploy All Services

To deploy all services for the default environment:

```bash
helmfile sync
```

To deploy all services for a specific environment (e.g., `development`):

```bash
helmfile --environments <environment-name> sync
```

### Deploy a Specific Service

To deploy a single service (e.g., `cert-manager`) for the default environment:

```bash
helmfile -l name=<service-name> sync
```

To deploy a single service for a specific environment:

```bash
helmfile --environments <environment-name> -l name=<service-name> sync
```

### Additional Commands

- **Dry Run**: Preview changes without applying them:

  ```bash
  helmfile --environments <environment-name> apply --dry-run
  ```

- **Destroy Services**: Remove all deployed releases (use with caution):

  ```bash
  helmfile destroy
  ```

## Development

### Fetching Default Values

This task is intended for maintainers to fetch the default values of Helm
charts. It should be run whenever the Helm chart versions are updated in
`helmfile.yaml`.

**IMPORTANT**: If you upgrade any chart version in `helmfile.yaml`, make sure to
update the corresponding version in this task as well.

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
