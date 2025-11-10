# Guide de Déploiement Rapide

## 📋 Étapes à suivre

### 1. Créer le repository GitHub

1. **Allez sur** : https://github.com/new
2. **Nom du repository** : `VOTRE-USERNAME.github.io`
   - ⚠️ Remplacez `VOTRE-USERNAME` par votre nom d'utilisateur GitHub exact
   - Exemple : si vous êtes `matty`, nommez-le `matty.github.io`
3. **Visibilité** : Public
4. **Ne cochez rien d'autre**
5. Cliquez sur **Create repository**

### 2. Modifier la configuration

Ouvrez `_config.yml` et modifiez ces lignes :

```yaml
url: "https://VOTRE-USERNAME.github.io"
github:
  username: "VOTRE-USERNAME"
```

### 3. Pousser sur GitHub

Ouvrez **PowerShell** dans ce dossier et exécutez :

```powershell
# Initialiser Git
git init

# Ajouter tous les fichiers
git add .

# Premier commit
git commit -m "Initial commit - TryHackMe writeups blog"

# Lier avec GitHub (remplacez VOTRE-USERNAME)
git remote add origin https://github.com/VOTRE-USERNAME/VOTRE-USERNAME.github.io.git

# Renommer la branche
git branch -M main

# Pousser
git push -u origin main
```

### 4. Activer GitHub Pages

1. Sur GitHub, allez dans votre repository
2. **Settings** → **Pages** (menu gauche)
3. Sous "Build and deployment" :
   - **Source** : Deploy from a branch
   - **Branch** : main
   - **Folder** : / (root)
4. **Save**

### 5. Attendre et visiter

- ⏱️ Attendez 2-5 minutes
- 🌐 Votre site sera sur : `https://VOTRE-USERNAME.github.io`

## ✅ C'est fait !

Votre blog est maintenant en ligne avec :
- ✨ Tous vos writeups
- 🏷️ Tags fonctionnels
- 📁 Catégories
- 🔍 Recherche
- 📱 Design responsive

## 🎨 Personnalisation (optionnel)

### Ajouter votre avatar

```powershell
# Créer le dossier
New-Item -ItemType Directory -Path "assets\img" -Force

# Copiez votre image dans assets\img\avatar.jpg
```

### Modifier le thème

Éditez `_config.yml` pour personnaliser couleurs, titre, etc.

## 📝 Ajouter de nouveaux writeups

1. Créez un fichier dans `_posts/` : `2025-02-10-tryhackme-nouvelle-room.md`
2. Ajoutez le frontmatter :

```yaml
---
title: 'TryHackMe - Nouvelle Room'
author: Matty
categories: [TryHackMe]
tags: [web, sqli]
date: 2025-02-10 12:00:00 +0100
image:
  path: /images/tryhackme_nouvelle_room/room_image.webp
---
```

3. Push sur GitHub :

```powershell
git add .
git commit -m "Add nouvelle room writeup"
git push
```

## 🆘 Problèmes ?

- **Le site ne s'affiche pas** : Attendez 5 minutes, vérifiez l'onglet **Actions** sur GitHub
- **Images manquantes** : Vérifiez que le dossier `images/` est bien poussé
- **Erreur 404** : Vérifiez que le nom du repository est bien `USERNAME.github.io`

Bonne chance ! 🚀
