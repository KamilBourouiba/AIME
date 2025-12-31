# Comment tester AIME

## 🎯 Méthodes de test disponibles

### 1. Tests unitaires Swift

Les tests unitaires sont dans `Tests/AIMETests/` et peuvent être exécutés avec :

```bash
cd AIME
swift test
```

**Ou avec Xcode** :
1. Ouvrez `Package.swift` dans Xcode
2. Appuyez sur `Cmd + U` pour exécuter les tests

### 2. Tests manuels avec Swift REPL

Pour tester rapidement les fonctionnalités de base :

```bash
cd AIME
swift
```

Puis dans le REPL :

```swift
import AIME

// Test de configuration
print("Version: \(AIME.version)")

// Test de logging
AIMELogger.shared.info("Test de logging")

// Test de traitement de texte
let text = "Hello world"
let isEmpty = TextProcessor.isEmpty(text)
print("Est vide: \(isEmpty)")

// Test de tokens
TokenTracker.shared.recordUsage(inputTokens: 100, outputTokens: 50)
let usage = TokenTracker.shared.getTotalUsage()
print("Tokens: \(usage.totalTokens)")
```

### 3. Créer une application de test SwiftUI

Créez un nouveau projet Xcode et ajoutez AIME comme dépendance locale :

**Étapes** :
1. Créez un nouveau projet iOS dans Xcode
2. File → Add Package Dependencies
3. Ajoutez le chemin local vers AIME
4. Utilisez le code d'exemple dans `Examples/AIMEExampleApp/`

### 4. Tests avec Playground

Créez un Playground Swift :

```swift
import AIME
import Foundation

// Test 1: Configuration
print("✅ Version: \(AIME.version)")

// Test 2: Logging
AIMELogger.shared.debug("Message de debug")
AIMELogger.shared.info("Message d'information")

// Test 3: TextProcessor
let chunks = TextProcessor.chunkText("Paragraphe 1.\n\nParagraphe 2.")
print("✅ Chunks: \(chunks.count)")

// Test 4: TokenTracker
TokenTracker.shared.reset()
TokenTracker.shared.recordUsage(inputTokens: 100, outputTokens: 50)
let usage = TokenTracker.shared.getTotalUsage()
print("✅ Tokens totaux: \(usage.totalTokens)")

// Test 5: Erreurs
let error = AIMEError.generationModelNotAvailable
print("✅ Erreur: \(error.localizedDescription)")
if let suggestion = error.recoverySuggestion {
    print("   Suggestion: \(suggestion)")
}

// Test 6: ActionItem
let item = ActionItem(
    title: "Tâche de test",
    priority: .high,
    owner: "Test User"
)
print("✅ ActionItem créé: \(item.title)")

// Test 7: Timeline
let timelineItem = TimelineItem(
    title: "Jalon de test",
    date: "2024-12-31",
    owner: "Test User"
)
print("✅ TimelineItem créé: \(timelineItem.title)")
```

## 🧪 Tests spécifiques par module

### Tests de base (fonctionnent toujours)

Ces tests ne nécessitent pas Apple Intelligence :

```swift
// ✅ Configuration
let config = AIME.defaultConfiguration
print(config.languageModel.useCase)

// ✅ Logging
AIMELogger.shared.info("Test")

// ✅ TextProcessor
TextProcessor.chunkText("Test")
TextProcessor.isEmpty("")
TextProcessor.truncate("Long text", maxLength: 5)

// ✅ TokenTracker
TokenTracker.shared.recordUsage(inputTokens: 10, outputTokens: 5)

// ✅ Erreurs
let error = AIMEError.textProcessingEmptyInput
print(error.localizedDescription)

// ✅ Modèles de données
let item = ActionItem(title: "Test")
let timeline = Timeline(items: [])
```

### Tests avec Apple Intelligence (nécessitent iOS 17+/macOS 14+)

Ces tests nécessitent Apple Intelligence disponible :

```swift
// Vérifier la disponibilité d'abord
if ModelAvailability.isAvailable() {
    // ✅ Question-Réponse
    let answer = try await QuestionAnswerer.ask(
        question: "Qu'est-ce que c'est ?",
        context: "C'est un test."
    )
    
    // ✅ Résumé
    let summary = try await Summarizer.generate(
        text: "Long texte...",
        style: .standard
    )
    
    // ✅ Action Items
    let items = try await ActionItemsExtractor.extract(
        text: "Réunion..."
    )
    
    // ✅ Timeline
    let timeline = try await TimelineExtractor.extract(
        text: "Projet..."
    )
} else {
    print("⚠️ Apple Intelligence non disponible")
}
```

## 📱 Test dans une application SwiftUI

### Code minimal pour tester

```swift
import SwiftUI
import AIME

struct TestView: View {
    @State private var result = ""
    
    var body: some View {
        VStack {
            Text("Test AIME")
            
            Button("Tester") {
                testAIME()
            }
            
            Text(result)
        }
    }
    
    func testAIME() {
        // Test de base
        AIMELogger.shared.info("Test depuis SwiftUI")
        
        // Test de tokens
        TokenTracker.shared.recordUsage(inputTokens: 100, outputTokens: 50)
        let usage = TokenTracker.shared.getTotalUsage()
        
        result = "Tokens: \(usage.totalTokens)"
    }
}
```

## 🔍 Vérification rapide

Exécutez ce script pour vérifier que tout fonctionne :

```bash
cd AIME
swift build
```

Si la compilation réussit, le package est prêt à être utilisé !

## 📊 Checklist de tests

### Tests de base
- [ ] Le package compile (`swift build`)
- [ ] La version est accessible (`AIME.version`)
- [ ] Le logging fonctionne (`AIMELogger.shared.info()`)
- [ ] TextProcessor fonctionne (`TextProcessor.chunkText()`)
- [ ] TokenTracker fonctionne (`TokenTracker.shared.recordUsage()`)
- [ ] Les erreurs ont des messages (`AIMEError.localizedDescription`)

### Tests avancés (nécessitent Apple Intelligence)
- [ ] ModelAvailability détecte la disponibilité
- [ ] QuestionAnswerer génère des réponses
- [ ] Summarizer génère des résumés
- [ ] ActionItemsExtractor extrait les items
- [ ] TimelineExtractor extrait les timelines
- [ ] Transcriber enregistre et transcrit

## 🐛 Dépannage

### Erreur de compilation

Si vous avez des erreurs de compilation :
1. Vérifiez que vous utilisez Swift 5.9+
2. Vérifiez que FoundationModels est disponible
3. Vérifiez les versions d'iOS/macOS requises

### Apple Intelligence non disponible

Si Apple Intelligence n'est pas disponible :
- Vérifiez que vous êtes sur iOS 17+ / macOS 14+
- Vérifiez que vous êtes dans une région supportée
- Utilisez `ModelAvailability.isAvailable()` pour vérifier

## 📚 Ressources

- `TESTING.md` - Guide complet de test
- `EXAMPLES.md` - Exemples d'utilisation
- `DOCUMENTATION.md` - Documentation complète

