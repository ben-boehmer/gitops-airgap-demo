# Deployment – hello-service (dev)

## Normaler Deploy-Flow

1. Commit auf `main`
2. CI baut Docker-Image
3. Image wird in lokales Registry / kind geladen
4. Helm values werden aktualisiert
5. Argo CD synchronisiert automatisch

## Wichtige Punkte
- Namespace: hello
- ArgoCD App: hello-service
- Helm Chart Pfad: apps/hello-service/chart

## Checks nach dem Deploy
- ArgoCD App Status = Healthy
- Pod läuft
- Service erreichbar auf Port XYZ
