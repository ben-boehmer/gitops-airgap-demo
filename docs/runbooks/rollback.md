# Rollback – hello-service

## Szenario
Deployment ist fehlerhaft, App startet nicht.

## Vorgehen

1. Letzten funktionierenden Commit identifizieren
2. Commit revertieren:
   git revert <commit-hash>
3. Push nach main
4. ArgoCD synchronisiert automatisch

## Alternativ (manuell)
- ArgoCD UI
- Sync auf vorherige Revision
