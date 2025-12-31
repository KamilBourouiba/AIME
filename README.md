# AIME v3.0 - Apple Intelligence Made Easy

## 🎯 API Simplifiée Style OpenAI

AIME v3.0 est une API ultra-simplifiée pour utiliser FoundationModels. **Aucun prompt n'est hardcodé dans le package**. Tout est dans votre code SwiftUI !

## ✨ Syntaxe Ultra-Simple

### Style OpenAI

```swift
import AIME
import FoundationModels

// 1. Créer votre type Generable
@Generable
struct MyAnswer {
    @Guide(description: "La réponse")
    var answer: String
}

// 2. Créer un client (comme OpenAI)
let client = try AIME.client(
    systemPrompt: "Tu es un expert en SwiftUI"  // Votre prompt système
)

// 3. Générer (comme OpenAI)
let response = try await client.generate(
    prompt: "Explique-moi SwiftUI",
    generating: MyAnswer.self
)

print(response.answer)
```

## 🚀 Exemples Complets

### Question-Réponse

```swift
@Generable
struct Answer {
    @Guide(description: "La réponse")
    var answer: String
}

let client = try AIME.client(
    systemPrompt: "Tu es un assistant expert qui répond aux questions."
)

let prompt = """
Question: Quelle est la capitale de la France?
Contexte: La France est un pays européen...
"""

let response = try await client.generate(
    prompt: prompt,
    generating: Answer.self
)
```

### Résumé

```swift
@Generable
struct Summary {
    @Guide(description: "Le résumé")
    var summary: String
    
    @Guide(description: "Points clés")
    var keyPoints: [String]?
}

let client = try AIME.client(
    systemPrompt: "Tu es un expert en résumé de texte."
)

let prompt = """
Résume le texte suivant en 3 phrases.
Extrais les 3 points clés les plus importants.

Texte:
\(monLongTexte)
"""

let summary = try await client.generate(
    prompt: prompt,
    generating: Summary.self
)
```

### Action Items

```swift
@Generable
struct ActionItems {
    @Guide(description: "Liste des action items")
    var items: [String]
}

let client = try AIME.client(
    systemPrompt: "Tu es un expert en extraction d'action items."
)

let prompt = """
Extrais tous les action items du texte suivant.
Retourne une liste claire.

Texte:
\(texteReunion)
"""

let actionItems = try await client.generate(
    prompt: prompt,
    generating: ActionItems.self
)
```

### Streaming

```swift
let response = try await client.generateStreaming(
    prompt: "Explique-moi SwiftUI",
    generating: Answer.self,
    onUpdate: { partialResponse in
        print("Mise à jour: \(partialResponse.answer ?? "")")
    }
)
```

## 📊 Logs de Tokens

Les tokens sont automatiquement enregistrés :

```swift
let usage = TokenTracker.shared.getTotalUsage()
print("Total: \(usage.totalTokens)")
```

## ✅ Avantages

1. **Ultra-Simple** - Syntaxe style OpenAI
2. **100% Personnalisable** - Tous vos prompts dans votre code
3. **Aucun Prompt Hardcodé** - Le package ne contient aucun prompt
4. **Type-Safe** - Vos propres types Generable
5. **Flexible** - Écrivez vos prompts comme vous voulez

## 🎨 Exemple SwiftUI Complet

```swift
import SwiftUI
import AIME
import FoundationModels

@Generable
struct Answer {
    @Guide(description: "La réponse")
    var answer: String
}

struct ContentView: View {
    @State private var response: Answer?
    @State private var myPrompt = "Explique-moi SwiftUI"
    @State private var mySystemPrompt = "Tu es un expert en développement iOS"
    
    var body: some View {
        VStack {
            TextField("Votre prompt", text: $myPrompt)
            
            Button("Générer") {
                Task {
                    let client = try AIME.client(systemPrompt: mySystemPrompt)
                    response = try await client.generate(
                        prompt: myPrompt,
                        generating: Answer.self
                    )
                }
            }
            
            if let response = response {
                Text(response.answer)
            }
        }
    }
}
```

## 📖 Documentation

- Voir `Examples/AIMEExampleApp/SimpleExample.swift` pour un exemple complet
- Tous vos prompts sont dans votre code SwiftUI
- Modifiez-les comme vous voulez !
