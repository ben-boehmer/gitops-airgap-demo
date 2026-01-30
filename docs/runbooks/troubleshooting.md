# Troubleshooting – hello-service

## Pod startet nicht
- kubectl logs <pod>
- häufige Ursache: falsche env vars

## ArgoCD App stuck in "Progressing"
- Helm Chart invalid
- values.yaml prüfen

## Image nicht gefunden
- Wurde load-images.sh ausgeführt?
- kind Registry erreichbar?
