#!/usr/bin/env bash

# -------------------------------------------------------------------
# # Release-Skript für den lokalen GitOps-Workflow
#
# Ablauf:
# - Version erhöhen
# - Docker-Image bauen
# - Image in den kind-Cluster laden
# - alte values.yaml sichern
# - neuen Image-Tag in values.yaml schreiben
# - Änderungen committen und pushen
#
# Dieses Skript simuliert einen air-gapped Workflow:
# - Images werden lokal gebaut
# - Images werden explizit in den Cluster geladen
# - zur Laufzeit werden keine Images aus einer Registry gezogen
#
# Versionierung:
# - Standardmäßig wird die Patch-Version erhöht
# - Mit --minor wird die Minor-Version erhöht
# - Mit --major wird die Major-Version erhöht
# - Der finale Image-Tag enthält zusätzlich den aktuellen Git-Commit-Hash
#
# Zusätzlich:
# - Die ArgoCD-/Helm-values.yaml wird automatisch auf den neuen Tag gesetzt
# - Vorher wird die alte values.yaml gesichert unter:
#   old_values_yamls/values_TAG.yaml
#   wobei TAG der bisherige Wert aus image.tag ist
# -------------------------------------------------------------------

set -euo pipefail

GRUEN='\033[0;32m'
ROT='\033[0;31m'
GELB='\033[1;33m'
RESET='\033[0m'

CLUSTER_NAME="gitops-dev"
IMAGE_NAME="hello-service"
TAG_FILE=".last_image_tag"
DEFAULT_TAG="0.1.0"
VERSION_BUMP="patch"

VALUES_FILE="${HOME}/gitops-airgap-demo/apps/hello-service/chart/values.yaml"
BACKUP_DIR="${HOME}/gitops-airgap-demo/apps/hello-service/chart/old_values_yamls"

zeige_hilfe() {
  cat <<EOF
Verwendung: $(basename "$0") [OPTION]

Optionen:
  --patch    Erhöht die Patch-Version (Standard)
  --minor    Erhöht die Minor-Version
  --major    Erhöht die Major-Version
  -h, --help Zeigt diese Hilfe an

Beispiele:
  $(basename "$0")
  $(basename "$0") --minor
  $(basename "$0") --major
EOF
}

for arg in "$@"; do
  case "$arg" in
    --patch)
      VERSION_BUMP="patch"
      ;;
    --minor)
      VERSION_BUMP="minor"
      ;;
    --major)
      VERSION_BUMP="major"
      ;;
    -h|--help)
      zeige_hilfe
      exit 0
      ;;
    *)
      echo -e "${ROT}Fehler: Unbekannte Option '$arg'.${RESET}"
      echo
      zeige_hilfe
      exit 1
      ;;
  esac
done

if [[ -f "$TAG_FILE" ]]; then
  DEFAULT_TAG="$(cat "$TAG_FILE")"
fi

BASE_VERSION="${DEFAULT_TAG%%-*}"

if [[ ! "$BASE_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo -e "${ROT}Fehler: Ungültiges Versionsformat in '$TAG_FILE': '$DEFAULT_TAG'${RESET}"
  echo "Erwartet wird das Format MAJOR.MINOR.PATCH, zum Beispiel 1.2.3"
  exit 1
fi

IFS='.' read -r MAJOR MINOR PATCH <<< "$BASE_VERSION"

case "$VERSION_BUMP" in
  patch)
    PATCH=$((PATCH + 1))
    ;;
  minor)
    MINOR=$((MINOR + 1))
    PATCH=0
    ;;
  major)
    MAJOR=$((MAJOR + 1))
    MINOR=0
    PATCH=0
    ;;
esac

NEW_VERSION="${MAJOR}.${MINOR}.${PATCH}"

if ! GIT_COMMIT_HASH="$(git rev-parse --short HEAD 2>/dev/null)"; then
  echo -e "${ROT}Fehler: Konnte keinen Git-Commit-Hash ermitteln.${RESET}"
  echo "Bitte stelle sicher, dass das Skript in einem Git-Repository ausgeführt wird."
  exit 1
fi

IMAGE_TAG="${NEW_VERSION}-${GIT_COMMIT_HASH}"

echo "$NEW_VERSION" > "$TAG_FILE"

APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../apps/hello-service/app" && pwd)"

echo "Alte Basisversion: ${BASE_VERSION}"
echo "Neue Basisversion: ${NEW_VERSION}"
echo "Verwendeter Git-Hash: ${GIT_COMMIT_HASH}"
echo "Erzeuge Image: ${IMAGE_NAME}:${IMAGE_TAG}"

docker build -t "${IMAGE_NAME}:${IMAGE_TAG}" "${APP_DIR}"

echo "Lade Image in den kind-Cluster '${CLUSTER_NAME}'"
kind load docker-image --name "${CLUSTER_NAME}" "${IMAGE_NAME}:${IMAGE_TAG}"

if [[ ! -f "$VALUES_FILE" ]]; then
  echo -e "${ROT}Fehler: Die values-Datei wurde nicht gefunden:${RESET} $VALUES_FILE"
  exit 1
fi

if ! command -v yq >/dev/null 2>&1; then
  echo -e "${ROT}Fehler: 'yq' ist nicht installiert.${RESET}"
  echo "Bitte installiere yq, damit die values.yaml sauber aktualisiert werden kann."
  exit 1
fi

mkdir -p "${BACKUP_DIR}"

ALTER_VALUES_TAG="$(yq -r '.image.tag' "${VALUES_FILE}")"

if [[ -z "${ALTER_VALUES_TAG}" || "${ALTER_VALUES_TAG}" == "null" ]]; then
  echo -e "${ROT}Fehler: Der bisherige Wert von 'image.tag' konnte nicht aus ${VALUES_FILE} gelesen werden.${RESET}"
  exit 1
fi

BACKUP_DATEI="${BACKUP_DIR}/values_${ALTER_VALUES_TAG}.yaml"

if [[ -f "${BACKUP_DATEI}" ]]; then
  echo -e "${GELB}Warnung: Die Sicherungsdatei existiert bereits und wird überschrieben:${RESET} ${BACKUP_DATEI}"
fi

cp "${VALUES_FILE}" "${BACKUP_DATEI}"

echo "Alte values.yaml wurde gesichert als: ${BACKUP_DATEI}"
echo "Aktualisiere ArgoCD-/Helm-values: ${VALUES_FILE}"
yq -i '.image.tag = "'"${IMAGE_TAG}"'"' "${VALUES_FILE}"

echo -e "${GRUEN}✔ Image wurde erfolgreich erzeugt und geladen.${RESET}"
echo -e "${GRUEN}✔ Alte values.yaml wurde gesichert.${RESET}"
echo -e "${GRUEN}✔ values.yaml wurde auf den neuen Tag aktualisiert.${RESET}"
echo "Finaler Image-Tag: ${IMAGE_NAME}:${IMAGE_TAG}"

if ! git diff --quiet; then
  git add "${VALUES_FILE}"
  git commit -m "Deployment: ${IMAGE_NAME} -> ${IMAGE_TAG}"
  git push
else
  echo "Keine Änderungen zum Committen vorhanden."
fi