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
fetch-default-values:
    bash ./scripts/fetch-default-values.sh

# Install all releases (sync) for a specific environment
install environment:
    helmfile --environment {{environment}} sync

# Uninstall all releases (destroy) for a specific environment
uninstall environment:
    helmfile --environment {{environment}} destroy

# Apply releases for a specific tier and environment
apply tier environment:
    helmfile --environment {{environment}} --selector tier={{tier}} apply

# Sync releases for a specific tier and environment
sync tier environment:
    helmfile --environment {{environment}} --selector tier={{tier}} sync

# Destroy releases for a specific tier and environment
destroy tier environment:
    helmfile --environment {{environment}} --selector tier={{tier}} destroy
