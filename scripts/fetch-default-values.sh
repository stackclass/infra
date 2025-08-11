#!/bin/bash
set -euo pipefail  # Fail on errors and undefined variables

# Add Helm repositories dynamically
if [[ -f "helmfile.yaml" ]]; then
    yq -o=json e '.repositories[] | {"name": .name, "url": .url}' helmfile.yaml | \
    jq -r '"helm repo add \(.name) \(.url)"' | \
    bash
    helm repo update
else
    echo "Error: helmfile.yaml not found."
    exit 1
fi

# Extract releases and process in a single pipeline
yq -o=json e '.releases[] | {"name": .name, "chart": .chart, "version": .version}' helmfile.yaml | \
jq -r '
    .name as $name |
    "mkdir -p values/\($name)\n" +
    "helm show values \(.chart) --version \(.version) > values/\($name)/values.yaml"
' | \
while read -r cmd; do
    eval "$cmd" || { echo "Failed: $cmd"; exit 1; }
done

echo "Default values files generated successfully."
