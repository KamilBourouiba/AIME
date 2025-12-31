# Instructions pour créer le dépôt Git et le pousser

## Option 1: Utiliser le script automatique (recommandé)

Exécutez simplement le script fourni :

```bash
cd AIME
./setup_git.sh
```

Le script va :
1. Initialiser le dépôt Git
2. Ajouter tous les fichiers
3. Créer le commit initial
4. Vous guider pour créer le dépôt sur GitHub

## Option 2: Commandes manuelles

### 1. Initialiser le dépôt Git

```bash
cd AIME
git init
git add .
git commit -m "Initial commit: AIME - Apple Intelligence Made Easy package"
```

### 2. Configurer Git (si nécessaire)

```bash
git config user.name "Kamil Bourouiba"
git config user.email "votre-email@example.com"
```

### 3. Créer le dépôt sur GitHub

#### Avec GitHub CLI (si installé)

```bash
# S'authentifier d'abord si nécessaire
gh auth login

# Créer le dépôt et pousser
gh repo create AIME \
    --public \
    --source=. \
    --remote=origin \
    --description "Apple Intelligence Made Easy - Package Swift pour intégrer Apple Intelligence dans vos applications SwiftUI" \
    --push
```

#### Manuellement via le site web

1. Allez sur https://github.com/new
2. Créez un nouveau dépôt nommé `AIME`
3. **Ne cochez pas** "Initialize with README" (le dépôt existe déjà)
4. Exécutez les commandes suivantes :

```bash
git remote add origin https://github.com/VOTRE_USERNAME/AIME.git
git branch -M main
git push -u origin main
```

## Vérification

Après avoir poussé, vous pouvez vérifier que tout fonctionne :

```bash
git remote -v
git log --oneline
```

Le dépôt devrait être accessible à l'URL :
`https://github.com/VOTRE_USERNAME/AIME`

## Structure du dépôt

Le dépôt contient :
- ✅ Code source complet dans `Sources/AIME/`
- ✅ Documentation complète (README.md, DOCUMENTATION.md, EXAMPLES.md)
- ✅ Guide de démarrage rapide (QUICK_START.md)
- ✅ Licence MIT
- ✅ Fichier .gitignore configuré

## Tags et versions

Pour créer une version taguée :

```bash
git tag -a v1.0.0 -m "Version 1.0.0 - Release initiale"
git push origin v1.0.0
```

## Mises à jour futures

Pour mettre à jour le dépôt après des modifications :

```bash
git add .
git commit -m "Description des changements"
git push
```

