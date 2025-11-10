# TryHackMe Writeups Blog

Ce blog contient mes writeups détaillés de TryHackMe.

## 🚀 Déploiement sur GitHub Pages

### Étape 1: Créer le repository GitHub

1. Allez sur https://github.com/new
2. Nommez votre repository: `VOTRE-USERNAME.github.io`
   - Remplacez `VOTRE-USERNAME` par votre nom d'utilisateur GitHub
   - Par exemple: `matty.github.io`
3. Mettez le repository en **Public**
4. Ne cochez rien d'autre (pas de README, .gitignore, etc.)
5. Cliquez sur **Create repository**

### Étape 2: Pousser votre blog sur GitHub

Ouvrez PowerShell dans ce dossier et exécutez:

```powershell
# Initialiser Git (si pas déjà fait)
git init

# Ajouter tous les fichiers
git add .

# Créer le premier commit
git commit -m "Initial commit - TryHackMe writeups blog"

# Ajouter votre repository GitHub
git remote add origin https://github.com/VOTRE-USERNAME/VOTRE-USERNAME.github.io.git

# Renommer la branche en main
git branch -M main

# Pousser sur GitHub
git push -u origin main
```

### Étape 3: Activer GitHub Pages

1. Allez sur votre repository GitHub
2. Cliquez sur **Settings** (⚙️)
3. Dans le menu de gauche, cliquez sur **Pages**
4. Sous "Build and deployment":
   - **Source**: Deploy from a branch
   - **Branch**: main
   - **Folder**: / (root)
5. Cliquez sur **Save**

### Étape 4: Attendre le déploiement

- GitHub va automatiquement construire votre site
- Cela prend 2-5 minutes la première fois
- Votre site sera accessible à: `https://VOTRE-USERNAME.github.io`

## 🎨 Personnalisation

### Modifier les informations du site

Éditez le fichier `_config.yml`:

```yaml
title: "Votre Titre"
tagline: "Votre tagline"
url: "https://VOTRE-USERNAME.github.io"
github:
  username: "VOTRE-USERNAME"
```

### Ajouter votre photo de profil

1. Créez le dossier: `assets/img/`
2. Ajoutez votre image: `assets/img/avatar.jpg`

## 📝 Ajouter de nouveaux articles

1. Créez un fichier dans `_posts/` avec le format: `YYYY-MM-DD-titre.md`
2. Ajoutez le frontmatter YAML en haut:

```yaml
---
title: 'Titre de votre writeup'
author: Matty
categories: [TryHackMe]
tags: [web, sqli, privesc]
date: 2025-01-10 12:00:00 +0100
image:
  path: /images/tryhackme_room/room_image.webp
---
```

3. Écrivez votre contenu en Markdown
4. Commit et push:

```powershell
git add .
git commit -m "Add new writeup"
git push
```

## 🏷️ Tags disponibles

Vos articles utilisent ces tags:
- web
- sqli
- xxe
- ssrf
- active directory
- privilege escalation
- Et bien d'autres...

## 🔧 Tester localement (optionnel)

Si vous voulez tester avant de publier:

```powershell
# Installer les dépendances
bundle install

# Lancer le serveur local
bundle exec jekyll serve

# Votre site sera sur http://localhost:4000
```

## 📚 Structure du projet

```
TryHackMe/
├── _config.yml          # Configuration du site
├── Gemfile              # Dépendances Ruby
├── Articles/            # Renommez en _posts/ (voir ci-dessous)
├── images/              # Vos images
└── README.md            # Ce fichier
```

## ⚠️ Important: Renommer le dossier Articles

GitHub Pages utilise le dossier `_posts/` (avec underscore). Il faut:

1. Supprimer l'ancien dossier `_posts/` (sauvegarde)
2. Renommer `Articles/` en `_posts/`

```powershell
Remove-Item "_posts" -Recurse -Force
Rename-Item "Articles" "_posts"
```

## 🆘 Aide

Si vous avez des problèmes:
1. Vérifiez l'onglet **Actions** sur GitHub pour voir les logs de build
2. Assurez-vous que tous les fichiers sont bien poussés
3. Attendez 5 minutes après chaque push

## 📖 Documentation

- [Jekyll](https://jekyllrb.com/)
- [Chirpy Theme](https://github.com/cotes2020/jekyll-theme-chirpy)
- [GitHub Pages](https://docs.github.com/en/pages)
