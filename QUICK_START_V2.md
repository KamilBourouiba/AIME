# 🚀 Quick Start - AIME v2.0

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/KamilBourouiba/AIME", from: "2.0.0")
]
```

## Utilisation en 3 Étapes

### 1️⃣ Créer votre type Generable

```swift
import AIME
import FoundationModels

@Generable
struct MyResponse {
    @Guide(description: "La réponse à votre question")
    var answer: String
}
```

### 2️⃣ Créer votre prompt

```swift
let prompt = PromptTemplates.questionAnswer(
    question: "Explique-moi SwiftUI",
    context: "SwiftUI est un framework..."
).build()
```

### 3️⃣ Générer la réponse

```swift
let response = try await LanguageModelHelper.generate<MyResponse>(
    prompt: prompt
)

print(response.answer)
```

## Exemple Complet SwiftUI

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
    
    var body: some View {
        VStack {
            Button("Poser question") {
                Task {
                    let prompt = PromptTemplates.questionAnswer(
                        question: "Qu'est-ce que SwiftUI?",
                        context: "SwiftUI est..."
                    ).build()
                    
                    response = try await LanguageModelHelper.generate<Answer>(
                        prompt: prompt
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

## Personnaliser votre Prompt

```swift
var builder = PromptBuilder()
builder.addSection(title: "Contexte", content: "Votre contexte...")
builder.addQuestion("Votre question")
builder.addInstruction("Soyez concis et précis")
let prompt = builder.build()
```

## Voir les Tokens Utilisés

```swift
let usage = TokenTracker.shared.getTotalUsage()
print("Total: \(usage.totalTokens)")
```

C'est tout ! 🎉

