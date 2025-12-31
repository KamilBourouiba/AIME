#!/bin/bash

# Script pour exécuter les tests AIME

set -e

echo "🧪 Exécution des tests AIME..."
echo ""

# Vérifier que nous sommes dans le bon répertoire
if [ ! -f "Package.swift" ]; then
    echo "❌ Erreur: Package.swift non trouvé. Exécutez ce script depuis le répertoire AIME."
    exit 1
fi

# Nettoyer les builds précédents
echo "🧹 Nettoyage des builds précédents..."
swift package clean

# Construire le package
echo "🔨 Construction du package..."
swift build

# Exécuter les tests
echo ""
echo "✅ Exécution des tests..."
echo ""
swift test

echo ""
echo "✨ Tests terminés avec succès!"

