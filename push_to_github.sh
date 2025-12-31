#!/bin/bash

# Script pour pousser AIME sur GitHub avec toutes les corrections

set -e

echo "🚀 Poussage d'AIME sur GitHub..."
echo ""

cd "/Users/apprenant122/Downloads/FMSample day 2 (1)/FMSample task 11 solution/AIME"

# Vérifier que nous sommes dans le bon répertoire
if [ ! -f "Package.swift" ]; then
    echo "❌ Erreur: Package.swift non trouvé. Exécutez ce script depuis le répertoire AIME."
    exit 1
fi

# Vérifier l'état Git
echo "📊 État du dépôt Git:"
git status --short
echo ""

# Ajouter tous les fichiers
echo "📝 Ajout des fichiers..."
git add -A

# Vérifier s'il y a des changements à commiter
if git diff --staged --quiet; then
    echo "ℹ️  Aucun changement à commiter."
else
    echo "💾 Création du commit..."
    git commit -m "Fix: Correction complète du manifeste Package.swift et annotations @available pour iOS 26.0

- Correction des versions de plateforme dans Package.swift (iOS 17+ au lieu de iOS 26)
- Ajout des annotations @available(iOS 26.0) pour toutes les APIs nécessaires
- Correction de l'erreur isEmpty dans ContentView
- Protection de defaultConfiguration avec guards #available
- Documentation complète des corrections"
fi

# Vérifier le remote
echo ""
echo "🔗 Remote configuré:"
git remote -v
echo ""

# Pousser sur GitHub
echo "📤 Poussage sur GitHub..."
if git push origin main; then
    echo "✅ Poussage réussi!"
else
    echo "❌ Erreur lors du poussage. Vérifiez votre connexion et vos permissions GitHub."
    exit 1
fi

# Créer et pousser le tag v1.0.0
echo ""
echo "🏷️  Création du tag v1.0.0..."
if git tag -a v1.0.0 -m "Version 1.0.0 - Release initiale d'AIME avec toutes les corrections" 2>/dev/null; then
    echo "📤 Poussage du tag..."
    git push origin v1.0.0
    echo "✅ Tag v1.0.0 créé et poussé!"
else
    echo "ℹ️  Le tag v1.0.0 existe déjà ou erreur lors de la création."
fi

echo ""
echo "✨ Terminé! Le package AIME est maintenant sur GitHub."
echo "🌐 URL: https://github.com/KamilBourouiba/AIME"
echo ""
echo "📋 Prochaines étapes dans Xcode:"
echo "   1. File → Packages → Reset Package Caches"
echo "   2. File → Packages → Resolve Package Versions"
echo "   3. Le package devrait maintenant se résoudre correctement!"

