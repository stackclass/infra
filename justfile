# List all available commands
default:
    just --list

# Linting
lint:
    helmfile --environment development lint
    helmfile --environment production lint

# Fetch default Helm chart values
# This task is intended for maintainers to fetch the default values of Helm charts.
# It should be run whenever the Helm chart versions are updated in `helmfile.yaml`.
# IMPORTANT: If you upgrade any chart version in `helmfile.yaml`, make sure to
# update the corresponding version in this task as well.
fetch-default-values:
    #!/bin/bash

    # Add Helm repositories (skip if already added)
    helm repo add bitnami https://charts.bitnami.com/bitnami
    helm repo add gitea-charts https://dl.gitea.com/charts/
    helm repo add harbor https://helm.goharbor.io
    helm repo add jetstack https://charts.jetstack.io
    helm repo add stackclass https://charts.stackclass.dev
    helm repo add tektoncd git+https://github.com/tektoncd/operator@charts?ref=v0.76.0
    helm repo update

    # Create directories for values files
    mkdir -p values/{cert-manager,gitea,harbor,stackclass,tekton}

    # Fetch and save default values for each chart
    helm show values jetstack/cert-manager --version v1.18.2 > values/cert-manager/values.yaml
    helm show values gitea-charts/gitea --version v12.1.3 > values/gitea/values.yaml
    helm show values harbor/harbor --version 1.17.1 > values/harbor/values.yaml
    helm show values stackclass/stackclass --version 0.10.6 > values/stackclass/values.yaml
    helm show values tektoncd/tekton-operator --version v0.76.0 > values/tekton/values.yaml

    echo "Default values files have been generated successfully."

# Install all releases (sync) for a specific environment
install environment:
    helmfile --environment {{environment}} sync

# Uninstall all releases (destroy) for a specific environment
uninstall environment:
    helmfile --environment {{environment}} destroy

# Apply the stackclass release for a specific environment
apply environment:
    helmfile --environment {{environment}} --selector name=stackclass apply

# Sync the stackclass release for a specific environment
sync environment:
    helmfile --environment {{environment}} --selector name=stackclass sync

# Destroy the stackclass release for a specific environment
destroy environment:
    helmfile --environment {{environment}} --selector name=stackclass destroy
