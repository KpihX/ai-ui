# 🚀 Open WebUI Deployment Suite

Interface web ChatGPT-like connectée à **Ollama** (modèles locaux), déployée comme service systemd persistent sur Ubuntu/Debian.

**Accès :** `http://ai.local:8765` — ajouter `127.0.0.1 ai.local` dans `/etc/hosts` si absent.

---

## 🔍 Vue d'ensemble

- **Automatisé** : Installation via un script unique (`make install`).
- **Persistant** : Démarrage automatique au boot via systemd.
- **Isolé** : Déploiement dans `/opt/open-webui`, config source dans ce repo.

## 🛠 Prérequis

1. **Docker & Docker Compose** installé.
2. **Ollama** installé comme service système (`systemctl status ollama`).
3. **Privilèges Sudo** pour la configuration systemd et UFW.
4. Ajouter dans `/etc/hosts` :
   ```
   127.0.0.1 ai.local
   ```

## 🚀 Installation

```bash
make install
# ou directement :
sudo ./install.sh
```

`install.sh` :
1. Nettoie les anciens conteneurs conflictuels
2. Configure Ollama sur `0.0.0.0:11434` (pour Docker)
3. Copie `docker-compose.yaml` → `/opt/open-webui/`
4. Crée et active `open-webui.service` (systemd)

## ⚙️ Gestion du Service

```bash
make start    # démarrer
make stop     # arrêter
make logs     # logs live
make status   # statut systemd
```

Ou directement :

| Action | Commande |
| :--- | :--- |
| Démarrer | `sudo systemctl start open-webui` |
| Arrêter | `sudo systemctl stop open-webui` |
| Redémarrer | `sudo systemctl restart open-webui` |
| Statut | `sudo systemctl status open-webui` |
| Logs | `journalctl -u open-webui.service -f` |

## 🏗 Architecture

```
Ollama (systemd, :11434)
    ↑ http://host.docker.internal:11434
Open WebUI (Docker, :8765 → container:8080)
    ↑ http://ai.local:8765
```

**Emplacements :**
- Config source : `~/Work/AI/ai_ui/`
- Install système : `/opt/open-webui/`
- Service : `/etc/systemd/system/open-webui.service`
- Override Ollama : `/etc/systemd/system/ollama.service.d/override.conf`

## ❓ Dépannage

**Aucun modèle dans l'interface :**
→ Settings > Connections — vérifier URL `http://host.docker.internal:11434` > Refresh.

**Conflit de conteneur :**
→ Relancer `make install` — le script nettoie automatiquement.

**Port déjà occupé :**
→ Changer le mapping dans `docker-compose.yaml` et relancer `make install`.
