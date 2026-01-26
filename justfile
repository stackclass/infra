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
    helmfile --environment {{ environment }} sync

# Uninstall all releases (destroy) for a specific environment
uninstall environment:
    helmfile --environment {{ environment }} destroy

# Apply releases for a specific tier and environment
apply tier environment:
    helmfile --environment {{ environment }} --selector tier={{ tier }} apply

# Sync releases for a specific tier and environment
sync tier environment:
    helmfile --environment {{ environment }} --selector tier={{ tier }} sync

# Destroy releases for a specific tier and environment
destroy tier environment:
    helmfile --environment {{ environment }} --selector tier={{ tier }} destroy

# Bump infra versions (interactive, fetches chart version from Helm repo)
bump-version:
    #!/usr/bin/env bash
    set -euo pipefail

    echo "Fetching latest chart version from Helm repo..."
    helm repo add stackclass https://charts.stackclass.dev > /dev/null 2>&1 || true
    helm repo update stackclass > /dev/null 2>&1
    latest_chart_version=$(helm search repo stackclass/stackclass --output json | jq -r '.[0].version')

    # Get current version
    current_chart_version=$(grep -A5 'name: stackclass$' helmfile.yaml | grep 'version:' | head -1 | sed -E 's/.*version: ([0-9]+\.[0-9]+\.[0-9]+).*/\1/')

    echo ""
    echo "Current chart version: $current_chart_version"
    echo "Latest chart release:  $latest_chart_version"
    echo ""

    # Prompt for version
    read -p "Chart version [$latest_chart_version]: " chart_version
    chart_version=${chart_version:-$latest_chart_version}

    echo ""

    # Validate version format
    if ! [[ "$chart_version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "Error: Chart version must be in format X.Y.Z"
        exit 1
    fi

    echo "=== Updating chart version ==="
    echo "Chart version: $chart_version"
    echo ""

    # Update helmfile.yaml stackclass version
    sed -i '' -E \
        '/name: stackclass$/,/version:/ s/version: [0-9]+\.[0-9]+\.[0-9]+/version: '"$chart_version"'/' \
        helmfile.yaml
    echo "✓ Updated helmfile.yaml (stackclass version)"

    echo ""
    echo "=== Fetching default values (will update image tags from chart) ==="
    just fetch-default-values

    echo ""
    echo "=== Linting helm charts ==="
    just lint

    echo ""
    echo "=== Done! Run 'just release' to commit and push. ==="

# Release infra (commit, push)
release:
    #!/usr/bin/env bash
    set -euo pipefail

    confirm() {
        read -p "$1 [y/N] " response
        case "$response" in
            [yY][eE][sS]|[yY]) return 0 ;;
            *) return 1 ;;
        esac
    }

    # Get current chart version
    chart_version=$(grep -A5 'name: stackclass$' helmfile.yaml | grep 'version:' | head -1 | sed -E 's/.*version: ([0-9]+\.[0-9]+\.[0-9]+).*/\1/')

    echo "=== Release infra ==="
    echo "Chart version: v$chart_version"
    echo ""

    echo "Changes to be committed:"
    git status --short
    echo ""

    # Step 1: Commit
    if confirm "Run 'git add -A && git commit'?"; then
        git add -A
        git commit -m "chore: update stackclass chart to $chart_version"
        echo ""
    else
        echo "Aborted at commit step."
        exit 0
    fi

    # Step 2: Push
    if confirm "Run 'git push origin main'?"; then
        git push origin main
        echo ""
        echo "=== Infra released! ==="
    else
        echo "Aborted at push step."
        exit 0
    fi
