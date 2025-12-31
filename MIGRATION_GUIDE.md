# 🔄 Guide de Migration - AIME v1.0 → v2.0

## Changements Majeurs

### ❌ Supprimé dans v2.0
- `QuestionAnswerer` - Créez votre propre type Generable
- `Summarizer` - Créez votre propre type Generable
- `ActionItemsExtractor` - Créez votre propre type Generable
- `TimelineExtractor` - Créez votre propre type Generable
- Tous les types `@Generable` internes

### ✅ Nouveau dans v2.0
- `LanguageModelHelper` - Helper principal pour générer avec vos types
- `PromptBuilder` - Builder pour créer des prompts facilement
- `PromptTemplates` - Templates prédéfinis
- `GenerableTemplates` - Exemples de structures à copier

## Migration Étape par Étape

### 1. Question-Réponse

**Avant (v1.0):**
```swift
let answer = try await QuestionAnswerer.ask(
    question: "Quelle est la capitale?",
    context: "La France est..."
)
```

**Après (v2.0):**
```swift
// 1. Créer votre type
@Generable
struct MyAnswer {
    @Guide(description: "La réponse")
    var answer: String
}

// 2. Créer le prompt
let prompt = PromptTemplates.questionAnswer(
    question: "Quelle est la capitale?",
    context: "La France est..."
).build()

// 3. Générer
let response = try await LanguageModelHelper.generate<MyAnswer>(
    prompt: prompt
)
print(response.answer)
```

### 2. Résumé

**Avant (v1.0):**
```swift
let summary = try await Summarizer.generate(
    text: "Long texte...",
    style: .standard
)
```

**Après (v2.0):**
```swift
@Generable
struct MySummary {
    @Guide(description: "Le résumé")
    var summary: String
}

let prompt = PromptTemplates.summary(
    text: "Long texte...",
    style: "standard"
).build()

let response = try await LanguageModelHelper.generate<MySummary>(
    prompt: prompt
)
print(response.summary)
```

### 3. Action Items

**Avant (v1.0):**
```swift
let items = try await ActionItemsExtractor.extract(
    text: "Réunion...",
    maxItems: 10
)
```

**Après (v2.0):**
```swift
@Generable
struct MyActionItems {
    @Guide(description: "Les action items")
    var items: [String]
}

let prompt = PromptTemplates.actionItems(text: "Réunion...").build()

let response = try await LanguageModelHelper.generate<MyActionItems>(
    prompt: prompt
)
for item in response.items {
    print(item)
}
```

### 4. Timeline

**Avant (v1.0):**
```swift
let timeline = try await TimelineExtractor.extract(
    text: "Réunion..."
)
```

**Après (v2.0):**
```swift
@Generable
struct MyTimeline {
    @Guide(description: "Les items de timeline")
    var items: [TimelineItem]?
}

@Generable
struct TimelineItem {
    @Guide(description: "Titre")
    var title: String
    
    @Guide(description: "Date")
    var date: String
}

let prompt = PromptTemplates.timeline(text: "Réunion...").build()

let response = try await LanguageModelHelper.generate<MyTimeline>(
    prompt: prompt
)
```

## Avantages de la Migration

1. **Contrôle Total** - Vous définissez exactement ce que vous voulez
2. **Flexibilité** - Adaptez les structures à vos besoins
3. **Simplicité** - Syntaxe claire et lisible
4. **Réutilisabilité** - Réutilisez vos types dans toute l'app
5. **Maintenabilité** - Tout est dans votre code, facile à modifier

## Exemples Complets

Voir `Examples/AIMEExampleApp/NewContentView.swift` pour des exemples complets.

