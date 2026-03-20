#!/usr/bin/env bash

# -------------------------------------------------------------------
# Release-Skript für den lokalen GitOps-Workflow
# 
# Dependency: yq Version >= 4.0.0 (zum Verändern der values.yaml)
#
# Ablauf:
# - Version erhöhen
# - Docker-Image bauen
# - Image in den kind-Cluster laden
# - alte values.yaml sichern
# - neuen Image-Tag in values.yaml schreiben
# - Änderungen committen und pushen
# -------------------------------------------------------------------


set -euo pipefail

CLUSTER_NAME="gitops-dev"
IMAGE_NAME="hello-service"
TAG_FILE=".last_image_tag"
DEFAULT_TAG="0.1.0"

# Load last tag if file exists
if [[ -f "$TAG_FILE" ]]; then
  DEFAULT_TAG="$(cat "$TAG_FILE")"
fi

read -rp "Enter image tag [${DEFAULT_TAG}]: " IMAGE_TAG
IMAGE_TAG="${IMAGE_TAG:-$DEFAULT_TAG}"

# Persist tag
echo "$IMAGE_TAG" > "$TAG_FILE"

APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../apps/hello-service/app" && pwd)"

echo "▶ Building image ${IMAGE_NAME}:${IMAGE_TAG}"
docker build -t "${IMAGE_NAME}:${IMAGE_TAG}" "${APP_DIR}"

echo "▶ Loading image into kind cluster '${CLUSTER_NAME}'"
kind load docker-image --name "${CLUSTER_NAME}" "${IMAGE_NAME}:${IMAGE_TAG}"

echo "✔ Image loaded successfully"