# 🚀 Open WebUI Deployment Suite

Cette suite d'outils permet de déployer et de gérer une instance professionnelle d'**Open WebUI** intégrée à **Ollama** sur un système Ubuntu/Debian. Elle automatise la configuration réseau, la sécurité (UFW) et l'intégration système via **systemd**.

## 📋 Table des Matières
- [Vue d'ensemble](#vue-densemble)
- [Prérequis](#prérequis)
- [Installation Rapide](#installation-rapide)
- [Gestion du Service](#gestion-du-service)
- [Architecture & Emplacements](#architecture--emplacements)
- [Configuration Ollama](#configuration-ollama)
- [Dépannage](#dépannage)

---

## 🔍 Vue d'ensemble

L'objectif de ce projet est de transformer un simple conteneur Docker en un **service système robuste**. 
- **Automatisé** : Installation via un script unique.
- **Persistant** : Démarrage automatique au boot du serveur.
- **Isolé** : Déploiement dans `/opt/open-webui` pour respecter la hiérarchie Linux.

## 🛠 Prérequis

Avant de commencer, assurez-vous d'avoir :
1. **Docker & Docker Compose** installé.
2. **Ollama** installé en tant que service système (`systemctl status ollama`).
3. **Privilèges Sudo** pour la configuration des services et du pare-feu.

## 🚀 Installation Rapide

Exécutez simplement le script d'installation depuis la racine du projet :

```bash
chmod +x install.sh
sudo ./install.sh
```

## ⚙️ Gestion du Service

| Action | Commande |
| :--- | :--- |
| **Démarrer** | `sudo systemctl start open-webui` |
| **Arrêter** | `sudo systemctl stop open-webui` |
| **Redémarrer** | `sudo systemctl restart open-webui` |
| **Statut** | `sudo systemctl status open-webui` |
| **Logs (Live)** | `journalctl -u open-webui.service -f` |

## 🏗 Architecture & Emplacements

- **Configuration Source** : `~/Work/AI/ai_ui/`
- **Installation Système** : `/opt/open-webui/`
- **Service Systemd** : `/etc/systemd/system/open-webui.service`
- **Override Ollama** : `/etc/systemd/system/ollama.service.d/override.conf`

## ❓ Dépannage

### Aucun modèle n'apparaît dans l'interface
1. Allez dans **Settings > Connections** dans Open WebUI.
2. Vérifiez que l'URL est `http://host.docker.internal:11434`.
3. Cliquez sur l'icône **Refresh**.

### Erreur de Conflit de Conteneur
Si le service échoue avec une erreur de conflit de nom, relancez simplement `sudo ./install.sh`. Le script est conçu pour nettoyer les anciens conteneurs automatiquement.

---
*Déployé avec ❤️ par l'Agent KpihX.*
