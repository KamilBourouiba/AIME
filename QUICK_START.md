# Guide de démarrage rapide - AIME

## Installation

1. Ajoutez AIME à votre projet Swift Package Manager
2. Importez le package : `import AIME`

## Exemples en 30 secondes

### Transcription vocale

```swift
let transcriber = Transcriber()
try await transcriber.startRecording()
// ... parler ...
try await transcriber.stopRecording()
print(transcriber.completeTranscript)
```

### Poser une question

```swift
let answer = try await QuestionAnswerer.ask(
    question: "Quels sont les points principaux ?",
    context: documentText
)
```

### Générer un résumé

```swift
let summary = try await Summarizer.generate(
    text: longDocument,
    style: .standard
)
```

### Extraire des action items

```swift
let items = try await ActionItemsExtractor.extract(
    text: meetingTranscript,
    maxItems: 10
)
```

### Extraire une timeline

```swift
let timeline = try await TimelineExtractor.extract(
    text: projectMeetings
)
```

## Configuration minimale

```swift
// Optionnel : configurer le logging
AIME.defaultConfiguration.logging.level = .info
AIME.defaultConfiguration.logging.logTokens = true
```

## Gestion des erreurs

```swift
do {
    let result = try await QuestionAnswerer.ask(...)
} catch AIMEError.generationModelNotAvailable {
    print("Apple Intelligence n'est pas disponible")
} catch {
    print("Erreur: \(error)")
}
```

## Documentation complète

- `README.md` - Vue d'ensemble
- `DOCUMENTATION.md` - Documentation complète
- `EXAMPLES.md` - Exemples détaillés

