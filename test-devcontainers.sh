#!/usr/bin/env bash
set -euo pipefail

# Test matrix
declare -a DEVCONTAINER_DIRS=(
  ".devcontainer/ubuntu-noble"
  ".devcontainer/fedora"
)

for DIR in "${DEVCONTAINER_DIRS[@]}"; do
  CONFIG_FILE="$DIR/devcontainer.json"
  echo "=== Testing with $CONFIG_FILE ==="
  # Copy config to project root as .devcontainer.json
  cp "$CONFIG_FILE" .devcontainer.json
  # Bring up the devcontainer (builds if needed)
  devcontainer up --workspace-folder .
  # Run the install.sh script inside the devcontainer
  devcontainer exec --workspace-folder . bash ./install.sh
  # Clean up the devcontainer (removes container and volumes)
  devcontainer down --workspace-folder .
  # Remove the temp config
  rm .devcontainer.json
  echo "=== Finished $CONFIG_FILE ==="
  echo

done

echo "All devcontainer tests completed successfully."
