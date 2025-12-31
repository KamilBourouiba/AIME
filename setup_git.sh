#!/bin/bash

# Script pour initialiser le dépôt Git et le pousser sur GitHub
# Par Kamil Bourouiba

set -e

echo "🚀 Configuration du dépôt Git pour AIME..."

# Vérifier si on est déjà dans un dépôt Git
if [ -d ".git" ]; then
    echo "⚠️  Un dépôt Git existe déjà. Continuons..."
else
    echo "📦 Initialisation du dépôt Git..."
    git init
fi

# Ajouter tous les fichiers
echo "📝 Ajout des fichiers..."
git add .

# Configurer Git (si pas déjà configuré globalement)
if [ -z "$(git config user.name)" ]; then
    echo "⚙️  Configuration de Git..."
    git config user.name "Kamil Bourouiba"
    git config user.email "kamil@example.com"
fi

# Créer le commit initial
echo "💾 Création du commit initial..."
git commit -m "Initial commit: AIME - Apple Intelligence Made Easy package

- Transcription vocale en temps réel avec paramètres configurables
- Génération de texte (Q&A, résumés, action items, timelines)
- Système de logging complet avec suivi des tokens
- Gestion d'erreurs robuste avec messages en français
- Configuration flexible avec nombreux paramètres optionnels
- Documentation complète et exemples d'utilisation

Par Kamil Bourouiba"

echo "✅ Dépôt Git initialisé avec succès!"

# Vérifier si GitHub CLI est installé
if command -v gh &> /dev/null; then
    echo ""
    echo "🔐 GitHub CLI détecté. Voulez-vous créer le dépôt sur GitHub ?"
    echo "   Option 1: Créer automatiquement avec GitHub CLI"
    echo "   Option 2: Créer manuellement et ajouter le remote"
    echo ""
    read -p "Choisissez une option (1 ou 2): " choice
    
    if [ "$choice" == "1" ]; then
        # Vérifier l'authentification GitHub
        if gh auth status &> /dev/null; then
            echo "📤 Création du dépôt sur GitHub..."
            gh repo create AIME \
                --public \
                --source=. \
                --remote=origin \
                --description "Apple Intelligence Made Easy - Package Swift pour intégrer Apple Intelligence dans vos applications SwiftUI" \
                --push
            
            echo "✅ Dépôt créé et poussé sur GitHub avec succès!"
            echo "🌐 URL: https://github.com/$(gh api user --jq .login)/AIME"
        else
            echo "❌ Vous devez vous authentifier avec GitHub CLI d'abord:"
            echo "   Exécutez: gh auth login"
            echo ""
            echo "Ensuite, créez le dépôt manuellement:"
            echo "   1. Allez sur https://github.com/new"
            echo "   2. Créez un nouveau dépôt nommé 'AIME'"
            echo "   3. Exécutez: git remote add origin https://github.com/VOTRE_USERNAME/AIME.git"
            echo "   4. Exécutez: git push -u origin main"
        fi
    else
        echo ""
        echo "📋 Pour créer le dépôt manuellement:"
        echo "   1. Allez sur https://github.com/new"
        echo "   2. Créez un nouveau dépôt nommé 'AIME'"
        echo "   3. Exécutez les commandes suivantes:"
        echo ""
        echo "      git remote add origin https://github.com/VOTRE_USERNAME/AIME.git"
        echo "      git branch -M main"
        echo "      git push -u origin main"
    fi
else
    echo ""
    echo "📋 Pour créer le dépôt sur GitHub:"
    echo "   1. Allez sur https://github.com/new"
    echo "   2. Créez un nouveau dépôt nommé 'AIME'"
    echo "   3. Exécutez les commandes suivantes:"
    echo ""
    echo "      git remote add origin https://github.com/VOTRE_USERNAME/AIME.git"
    echo "      git branch -M main"
    echo "      git push -u origin main"
fi

echo ""
echo "✨ Terminé!"

