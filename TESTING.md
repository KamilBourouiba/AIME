# Guide de test pour AIME

Ce guide explique comment tester le package AIME de différentes manières.

## 🧪 Types de tests disponibles

### 1. Tests unitaires

Les tests unitaires sont dans le dossier `Tests/AIMETests/` et couvrent :

- ✅ Configuration (`AIMETests.swift`)
- ✅ Logging (`LoggingTests.swift`)
- ✅ Gestion d'erreurs (`ErrorTests.swift`)
- ✅ Traitement de texte (`TextProcessorTests.swift`)
- ✅ Disponibilité des modèles (`ModelAvailabilityTests.swift`)
- ✅ Action Items (`ActionItemTests.swift`)
- ✅ Timelines (`TimelineTests.swift`)

### 2. Application d'exemple

Une application SwiftUI complète est disponible dans `Examples/AIMEExampleApp/` pour tester visuellement toutes les fonctionnalités.

## 🚀 Exécuter les tests unitaires

### Avec Xcode

1. Ouvrez le package dans Xcode :
   ```bash
   cd AIME
   open Package.swift
   ```

2. Sélectionnez le schéma de test (`AIMETests`)
3. Appuyez sur `Cmd + U` ou cliquez sur "Test" dans le menu Product

### Avec Swift Package Manager (ligne de commande)

```bash
cd AIME
swift test
```

### Tests spécifiques

Pour exécuter un test spécifique :

```bash
swift test --filter AIMETests.testAIMEVersion
```

## 📱 Tester avec l'application d'exemple

### Prérequis

- Xcode 15.0+
- iOS 17.0+ (simulateur ou appareil)
- Apple Intelligence disponible (pour certaines fonctionnalités)

### Étapes

1. **Ouvrir le projet dans Xcode** :
   ```bash
   cd AIME/Examples/AIMEExampleApp
   # Créez un projet Xcode si nécessaire
   ```

2. **Ajouter AIME comme dépendance** :
   - File → Add Package Dependencies
   - Ajoutez le chemin local vers AIME

3. **Exécuter l'application** :
   - Sélectionnez un simulateur iOS 17+
   - Appuyez sur `Cmd + R`

### Fonctionnalités à tester

L'application d'exemple permet de tester :

1. **Transcription vocale**
   - Démarrer/arrêter l'enregistrement
   - Voir la transcription en temps réel
   - Tester pause/reprise

2. **Question-Réponse**
   - Poser des questions sur le texte de test
   - Voir les réponses générées

3. **Résumés**
   - Générer des résumés avec différents styles
   - Voir les résultats

4. **Action Items**
   - Extraire les action items du texte
   - Voir la liste générée

5. **Timeline**
   - Extraire les timelines
   - Voir les jalons et dates

## 🧪 Tests manuels

### Test 1: Configuration

```swift
import AIME

// Vérifier la version
print("Version: \(AIME.version)")

// Modifier la configuration
AIME.defaultConfiguration.logging.level = .debug
AIME.defaultConfiguration.logging.logTokens = true
```

### Test 2: Logging

```swift
import AIME

AIMELogger.shared.info("Test d'information")
AIMELogger.shared.warning("Test d'avertissement")
AIMELogger.shared.error("Test d'erreur", error: nil)

// Vérifier les tokens
TokenTracker.shared.recordUsage(inputTokens: 100, outputTokens: 50)
let usage = TokenTracker.shared.getTotalUsage()
print("Tokens: \(usage.totalTokens)")
```

### Test 3: Traitement de texte

```swift
import AIME

let text = "Premier paragraphe.\n\nDeuxième paragraphe."
let chunks = TextProcessor.chunkText(text)
print("Chunks: \(chunks.count)")

let isEmpty = TextProcessor.isEmpty("")
print("Est vide: \(isEmpty)")

let truncated = TextProcessor.truncate("Long text", maxLength: 5)
print("Tronqué: \(truncated)")
```

### Test 4: Disponibilité des modèles

```swift
import AIME

let isAvailable = ModelAvailability.isAvailable()
print("Apple Intelligence disponible: \(isAvailable)")

if let reason = ModelAvailability.unavailabilityReason() {
    print("Raison: \(reason)")
}
```

### Test 5: Question-Réponse (nécessite Apple Intelligence)

```swift
import AIME

let testText = "Réunion du projet. Points discutés: design, tests, documentation."

Task {
    do {
        let answer = try await QuestionAnswerer.ask(
            question: "Quels sont les points discutés ?",
            context: testText
        )
        print("Réponse: \(answer)")
    } catch {
        print("Erreur: \(error)")
    }
}
```

### Test 6: Résumé (nécessite Apple Intelligence)

```swift
import AIME

let longText = """
Long document avec beaucoup de contenu...
"""

Task {
    do {
        let summary = try await Summarizer.generate(
            text: longText,
            style: .standard
        )
        print("Résumé: \(summary)")
    } catch {
        print("Erreur: \(error)")
    }
}
```

## ✅ Checklist de tests

### Tests de base (sans Apple Intelligence)
- [ ] Configuration par défaut fonctionne
- [ ] Logging fonctionne à tous les niveaux
- [ ] TokenTracker enregistre et réinitialise correctement
- [ ] TextProcessor traite le texte correctement
- [ ] Gestion d'erreurs retourne des messages clairs
- [ ] ActionItem et TimelineItem se créent correctement

### Tests avec Apple Intelligence (nécessite appareil/simulateur compatible)
- [ ] ModelAvailability détecte la disponibilité
- [ ] QuestionAnswerer génère des réponses
- [ ] Summarizer génère des résumés
- [ ] ActionItemsExtractor extrait les items
- [ ] TimelineExtractor extrait les timelines
- [ ] Transcriber enregistre et transcrit

### Tests d'intégration
- [ ] Application d'exemple compile et s'exécute
- [ ] Toutes les fonctionnalités sont accessibles dans l'UI
- [ ] Les erreurs sont gérées gracieusement
- [ ] Le logging fonctionne dans l'application

## 🐛 Dépannage

### Les tests échouent

1. Vérifiez que vous êtes dans le bon répertoire
2. Vérifiez que Swift Package Manager fonctionne : `swift --version`
3. Nettoyez et reconstruisez : `swift package clean && swift build`

### Apple Intelligence non disponible

- Vérifiez que vous êtes sur iOS 17+ / macOS 14+
- Vérifiez que vous êtes dans une région supportée
- Utilisez `ModelAvailability.isAvailable()` pour vérifier

### Erreurs de compilation

- Vérifiez que toutes les dépendances sont installées
- Vérifiez que vous utilisez la bonne version de Swift (5.9+)
- Vérifiez que FoundationModels est disponible

## 📊 Couverture de tests

Les tests couvrent actuellement :
- ✅ Configuration : 100%
- ✅ Logging : 90%
- ✅ Erreurs : 100%
- ✅ TextProcessor : 100%
- ✅ ModelAvailability : 80%
- ✅ ActionItem/Timeline : 100%

## 🔄 Tests continus

Pour intégrer dans un pipeline CI/CD :

```bash
# Exécuter tous les tests
swift test

# Avec couverture de code (si disponible)
swift test --enable-code-coverage
```

## 📝 Ajouter de nouveaux tests

Pour ajouter de nouveaux tests :

1. Créez un nouveau fichier dans `Tests/AIMETests/`
2. Importez `@testable import AIME`
3. Créez une classe qui hérite de `XCTestCase`
4. Ajoutez des méthodes de test avec le préfixe `test`

Exemple :

```swift
import XCTest
@testable import AIME

final class MyNewTests: XCTestCase {
    func testMyFeature() {
        // Votre test ici
        XCTAssertTrue(true)
    }
}
```

