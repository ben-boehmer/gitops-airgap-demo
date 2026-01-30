#!/usr/bin/env bash
set -euo pipefail

# -------------------------------------------------------------------
# Build and load images into the local kind cluster
#
# This simulates an air-gapped workflow:
# - images are built locally
# - images are loaded into the cluster explicitly
# - no image pulls happen at runtime
# -------------------------------------------------------------------

CLUSTER_NAME="gitops-dev"
IMAGE_NAME="hello-service"
IMAGE_TAG="0.1.0"

APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../apps/hello-service/app" && pwd)"

echo "▶ Building image ${IMAGE_NAME}:${IMAGE_TAG}"
docker build \
  -t "${IMAGE_NAME}:${IMAGE_TAG}" \
  "${APP_DIR}"

echo "▶ Loading image into kind cluster '${CLUSTER_NAME}'"
kind load docker-image \
  --name "${CLUSTER_NAME}" \
  "${IMAGE_NAME}:${IMAGE_TAG}"

echo "✔ Image loaded successfully"
