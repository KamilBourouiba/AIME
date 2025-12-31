# AIME v2.0 - Apple Intelligence Made Easy

## 🎯 Nouvelle Architecture - 100% Personnalisable

AIME v2.0 a été complètement refait pour être **100% personnalisable**. Aucun prompt ou type `@Generable` n'est défini dans le package. **Vous créez tout dans votre propre code !**

## ✨ Concepts Clés

### 1. **LanguageModelHelper** - Helper principal
Utilisez `LanguageModelHelper` pour générer des réponses avec vos propres types Generable.

### 2. **PromptBuilder** - Création de prompts simple
Utilisez `PromptBuilder` pour créer des prompts de manière lisible et modulaire.

### 3. **PromptTemplates** - Templates prédéfinis
Utilisez les templates pour démarrer rapidement, puis personnalisez-les.

## 🚀 Démarrage Rapide

### Étape 1 : Créer votre type Generable

```swift
import AIME
import FoundationModels

@Generable
struct MyQuestionAnswer {
    @Guide(description: "La réponse à ma question")
    var answer: String
    
    @Guide(description: "Niveau de confiance (0-100)")
    var confidence: Int?
}
```

### Étape 2 : Créer votre prompt

```swift
// Option 1 : Utiliser PromptBuilder
var promptBuilder = PromptBuilder()
promptBuilder.addQuestion("Quelle est la capitale de la France?")
promptBuilder.addContext("La France est un pays européen...")
let prompt = promptBuilder.build()

// Option 2 : Utiliser un template
let prompt = PromptTemplates.questionAnswer(
    question: "Quelle est la capitale?",
    context: "La France est..."
).build()

// Option 3 : Écrire directement
let prompt = "Question: Quelle est la capitale de la France?"
```

### Étape 3 : Générer la réponse

```swift
let response = try await LanguageModelHelper.generate<MyQuestionAnswer>(
    prompt: prompt
)

print(response.answer)
if let confidence = response.confidence {
    print("Confiance: \(confidence)%")
}
```

## 📚 Exemples Complets

### Exemple 1 : Question-Réponse Personnalisée

```swift
import SwiftUI
import AIME
import FoundationModels

@Generable
struct CustomQA {
    @Guide(description: "La réponse")
    var answer: String
    
    @Guide(description: "Sources utilisées")
    var sources: [String]?
}

struct MyView: View {
    @State private var response: CustomQA?
    
    var body: some View {
        Button("Poser question") {
            Task {
                let prompt = PromptTemplates.questionAnswer(
                    question: "Explique-moi SwiftUI",
                    context: "SwiftUI est un framework..."
                ).build()
                
                response = try await LanguageModelHelper.generate<CustomQA>(
                    prompt: prompt
                )
            }
        }
        
        if let response = response {
            Text(response.answer)
        }
    }
}
```

### Exemple 2 : Résumé avec Points Clés

```swift
@Generable
struct MySummary {
    @Guide(description: "Le résumé en 3 phrases")
    var summary: String
    
    @Guide(description: "Les 5 mots-clés les plus importants")
    var keywords: [String]
}

let prompt = PromptTemplates.summary(
    text: "Votre long texte ici...",
    style: "professionnel"
).build()

let summary = try await LanguageModelHelper.generate<MySummary>(
    prompt: prompt
)

print(summary.summary)
for keyword in summary.keywords {
    print("- \(keyword)")
}
```

### Exemple 3 : Action Items Structurés

```swift
@Generable
struct MyActionItems {
    @Guide(description: "Les tâches à faire")
    var tasks: [TaskItem]
}

@Generable
struct TaskItem {
    @Guide(description: "Titre de la tâche")
    var title: String
    
    @Guide(description: "Personne responsable")
    var assignee: String
    
    @Guide(description: "Date d'échéance")
    var dueDate: String
    
    @Guide(description: "Priorité (haute, moyenne, basse)")
    var priority: String
}

let prompt = PromptTemplates.actionItems(
    text: "Réunion du projet..."
).build()

let actionItems = try await LanguageModelHelper.generate<MyActionItems>(
    prompt: prompt
)

for task in actionItems.tasks {
    print("\(task.title) - \(task.assignee) - \(task.dueDate)")
}
```

## 🔧 API Principale

### LanguageModelHelper

```swift
// Créer une session
let session = try LanguageModelHelper.createSession(
    useCase: .general,
    instructions: "Tu es un expert..."
)

// Générer une réponse
let response = try await LanguageModelHelper.generate<YourType>(
    prompt: "Votre prompt",
    session: session  // optionnel
)

// Générer en streaming
let response = try await LanguageModelHelper.generateStreaming<YourType>(
    prompt: "Votre prompt",
    onUpdate: { partialResponse in
        print("Mise à jour: \(partialResponse)")
    }
)
```

### PromptBuilder

```swift
var builder = PromptBuilder()
builder.addSection(title: "Contexte", content: "...")
builder.addQuestion("Votre question")
builder.addInstruction("Soyez concis")
let prompt = builder.build()
```

### PromptTemplates

```swift
// Question-Réponse
PromptTemplates.questionAnswer(question: "...", context: "...")

// Résumé
PromptTemplates.summary(text: "...", style: "professionnel")

// Action Items
PromptTemplates.actionItems(text: "...")

// Timeline
PromptTemplates.timeline(text: "...")
```

## 📊 Logs de Tokens

Les tokens sont automatiquement enregistrés. Utilisez `TokenTracker.shared` :

```swift
let usage = TokenTracker.shared.getTotalUsage()
print("Total: \(usage.totalTokens)")
print("Input: \(usage.inputTokens)")
print("Output: \(usage.outputTokens)")

let history = TokenTracker.shared.getUsageHistory()
for entry in history {
    print("\(entry.timestamp): \(entry.totalTokens) tokens")
}
```

## ✅ Avantages de la Nouvelle Architecture

1. **100% Personnalisable** - Vous contrôlez tous les types et prompts
2. **Syntaxe Simple** - PromptBuilder rend la création facile
3. **Type-Safe** - Vos propres types Generable avec validation
4. **Flexible** - Adaptez à vos besoins spécifiques
5. **Pas de Couplage** - Aucun type imposé par le package
6. **Facile à Modifier** - Changez vos prompts directement dans votre code

## 🔄 Migration depuis v1.0

Si vous utilisiez AIME v1.0, voici comment migrer :

### Avant (v1.0)
```swift
let answer = try await QuestionAnswerer.ask(
    question: "Quelle est la capitale?",
    context: "La France..."
)
```

### Après (v2.0)
```swift
@Generable
struct MyAnswer {
    @Guide(description: "La réponse")
    var answer: String
}

let prompt = PromptTemplates.questionAnswer(
    question: "Quelle est la capitale?",
    context: "La France..."
).build()

let response = try await LanguageModelHelper.generate<MyAnswer>(
    prompt: prompt
)
```

## 📖 Documentation Complète

Voir `REFACTORING_GUIDE.md` pour plus de détails et d'exemples.

## 🎨 Exemple d'Application

Voir `Examples/AIMEExampleApp/NewContentView.swift` pour un exemple complet d'utilisation.

