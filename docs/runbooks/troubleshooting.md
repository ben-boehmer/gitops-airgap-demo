# Troubleshooting – hello-service

ImagePullBackOff error

## Fehlerbild



## Mögliche Ursachen

## Diagnose

## Lösung

## Projektspezifische Besonderheit


## Vault 403 – invalid token

### Fehlerbild
SecretStore not ready.
Vault antwortet bei /auth/token/lookup-self mit 403.

### Ursache
Der im Kubernetes-Secret hinterlegte statische Vault-Token ist
abgelaufen oder wurde invalidiert.

### Diagnose
kubectl get events -n demo

→ lookup-self
→ 403 invalid token

### Lösung
Neuen Vault-Token erzeugen und als Kubernetes-Secret aktualisieren.





## Pod startet nicht
- kubectl logs <pod>
- häufige Ursache: falsche env vars

## ArgoCD App stuck in "Progressing"
- Helm Chart invalid
- values.yaml prüfen

## Image nicht gefunden
- Wurde load-images.sh ausgeführt?
- kind Registry erreichbar?
- Image Tag in values.yaml und Chart.yaml in Helm aktualisiert?