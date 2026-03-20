# Rollback – hello-service

## Szenario
Deployment ist fehlerhaft, App startet nicht.

## Variante 1: Git revert:
1. Letzten funktionierenden Commit identifizieren
2. Commit revertieren:
   git revert <commit-hash>
3. Push nach main
4. ArgoCD synchronisiert automatisch

## Variante 1: altes Image verwenden:

Ein Rollback kann durchgeführt werden, indem eine vorherige
`values.yaml` wiederhergestellt wird.

Beispiel:

``` bash
cp apps/hello-service/chart/old_values_yamls/values_0.1.1.yaml apps/hello-service/chart/values.yaml
```
Danach:

``` bash
git add apps/hello-service/chart/values.yaml
git commit -m "Rollback auf Version 0.1.1"
git push
```