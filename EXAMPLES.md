# Exemples d'utilisation d'AIME

Ce document contient des exemples pratiques pour utiliser le package AIME dans vos applications SwiftUI.

## Configuration de base

```swift
import AIME

// Configuration personnalisée (optionnel)
AIME.defaultConfiguration = AIMEConfiguration(
    languageModel: LanguageModelConfiguration(
        useCase: .general,
        guardrails: .permissiveContentTransformations
    ),
    logging: LoggingConfiguration(
        isEnabled: true,
        level: .info,
        logTokens: true
    )
)
```

## Transcription vocale

### Transcription simple

```swift
import SwiftUI
import AIME

struct RecordingView: View {
    @StateObject private var transcriber = Transcriber()
    @State private var transcript = ""
    
    var body: some View {
        VStack {
            Text(transcriber.completeTranscript)
                .padding()
            
            if transcriber.isRecording {
                Button("Arrêter") {
                    Task {
                        try? await transcriber.stopRecording()
                    }
                }
            } else {
                Button("Démarrer") {
                    Task {
                        try? await transcriber.startRecording(
                            onTranscriptUpdate: { newTranscript in
                                transcript = String(newTranscript.characters)
                            },
                            onError: { error in
                                print("Erreur: \(error.localizedDescription)")
                            }
                        )
                    }
                }
            }
        }
    }
}
```

### Transcription avec configuration personnalisée

```swift
let transcriptionConfig = TranscriptionConfiguration(
    locale: Locale(identifier: "fr-FR"),
    bufferSize: 8192
)

let recordingConfig = RecordingConfiguration(
    saveToDisk: true,
    saveURL: FileManager.default.temporaryDirectory
)

let transcriber = Transcriber(
    transcriptionConfig: transcriptionConfig,
    recordingConfig: recordingConfig
)
```

## Question-Réponse

### Question simple

```swift
import AIME

Task {
    do {
        let answer = try await QuestionAnswerer.ask(
            question: "Quels sont les points principaux de cette réunion ?",
            context: documentText
        )
        print("Réponse: \(answer)")
    } catch {
        print("Erreur: \(error)")
    }
}
```

### Question avec streaming

```swift
Task {
    try await QuestionAnswerer.askStreaming(
        question: "Résume les décisions prises",
        context: meetingTranscript,
        onUpdate: { partialAnswer in
            // Mettre à jour l'UI avec la réponse partielle
            self.answer = partialAnswer
        },
        onError: { error in
            print("Erreur: \(error.localizedDescription)")
        }
    )
}
```

### Question avec paramètres avancés

```swift
let answer = try await QuestionAnswerer.ask(
    question: "Qui est responsable de cette tâche ?",
    context: projectDocumentation,
    useCase: .general,
    instructions: "Réponds de manière concise et professionnelle",
    includeCitation: true,
    timeout: 30
)
```

## Résumés

### Résumé simple

```swift
let summary = try await Summarizer.generate(
    text: longDocument,
    style: .standard
)
```

### Résumé avec style personnalisé

```swift
let conciseSummary = try await Summarizer.generate(
    text: meetingNotes,
    maxLength: 500,
    style: .concise
)

let bulletSummary = try await Summarizer.generate(
    text: report,
    style: .bulletPoints
)
```

### Résumé avec streaming

```swift
Task {
    try await Summarizer.generateStreaming(
        text: veryLongDocument,
        style: .detailed,
        onUpdate: { partialSummary in
            self.summaryText = partialSummary
        }
    )
}
```

## Action Items

### Extraction simple

```swift
let actionItems = try await ActionItemsExtractor.extract(
    text: meetingTranscript,
    maxItems: 10
)

for item in actionItems {
    print("- \(item.title)")
}
```

### Extraction avec streaming

```swift
Task {
    try await ActionItemsExtractor.extractStreaming(
        text: meetingNotes,
        maxItems: 15,
        onUpdate: { items in
            self.actionItems = items
        }
    )
}
```

## Timeline

### Extraction de timeline

```swift
let timeline = try await TimelineExtractor.extract(
    text: projectMeetingTranscripts
)

for item in timeline.items {
    print("\(item.title) - \(item.date)")
    if let owner = item.owner {
        print("  Propriétaire: \(owner)")
    }
    if let status = item.status {
        print("  Statut: \(status)")
    }
}
```

### Timeline avec streaming

```swift
Task {
    try await TimelineExtractor.extractStreaming(
        text: allMeetingNotes,
        onUpdate: { timeline in
            self.timelineItems = timeline.items
            self.extractionNotes = timeline.extractionNotes
        }
    )
}
```

## Gestion des erreurs

```swift
do {
    let result = try await QuestionAnswerer.ask(
        question: "Question",
        context: text
    )
} catch AIMEError.generationModelNotAvailable {
    // Gérer l'indisponibilité du modèle
    showAlert("Apple Intelligence n'est pas disponible")
} catch AIMEError.generationGuardrailViolation {
    // Gérer la violation des garde-fous
    showAlert("Le contenu généré viole les politiques de sécurité")
} catch AIMEError.transcriptionNotAuthorized {
    // Demander les autorisations
    showSettingsAlert()
} catch {
    // Autres erreurs
    print("Erreur: \(error.localizedDescription)")
}
```

## Logging et tokens

### Configuration du logging

```swift
AIME.defaultConfiguration.logging = LoggingConfiguration(
    isEnabled: true,
    level: .debug,
    logTokens: true,
    logErrors: true,
    logPerformance: true,
    customLogger: { entry in
        // Logger personnalisé
        print("[\(entry.level)] \(entry.message)")
    }
)
```

### Vérifier l'utilisation des tokens

```swift
let usage = TokenTracker.shared.getTotalUsage()
print("Tokens utilisés: \(usage.totalTokens)")
print("  Input: \(usage.inputTokens)")
print("  Output: \(usage.outputTokens)")

// Obtenir l'historique
let history = TokenTracker.shared.getUsageHistory()
```

## Vérification de disponibilité

```swift
// Vérifier si Apple Intelligence est disponible
if ModelAvailability.isAvailable() {
    // Utiliser les fonctionnalités
} else {
    if let reason = ModelAvailability.unavailabilityReason() {
        print("Raison: \(reason)")
    }
}

// Vérifier la transcription
let isAvailable = await ModelAvailability.isTranscriptionAvailable(locale: .current)
let isInstalled = await ModelAvailability.isTranscriptionModelInstalled(locale: .current)
```

## Exemple complet SwiftUI

```swift
import SwiftUI
import AIME

struct ContentView: View {
    @StateObject private var transcriber = Transcriber()
    @State private var question = ""
    @State private var answer = ""
    @State private var summary = ""
    
    var body: some View {
        NavigationView {
            VStack {
                // Transcription
                Section("Transcription") {
                    Text(transcriber.completeTranscript)
                        .frame(maxHeight: 200)
                    
                    if transcriber.isRecording {
                        Button("Arrêter") {
                            Task {
                                try? await transcriber.stopRecording()
                            }
                        }
                    } else {
                        Button("Démarrer") {
                            Task {
                                try? await transcriber.startRecording()
                            }
                        }
                    }
                }
                
                Divider()
                
                // Question-Réponse
                Section("Question") {
                    TextField("Posez une question", text: $question)
                    Button("Poser") {
                        Task {
                            do {
                                answer = try await QuestionAnswerer.ask(
                                    question: question,
                                    context: String(transcriber.completeTranscript.characters)
                                )
                            } catch {
                                print("Erreur: \(error)")
                            }
                        }
                    }
                    Text(answer)
                }
                
                Divider()
                
                // Résumé
                Section("Résumé") {
                    Button("Générer résumé") {
                        Task {
                            do {
                                summary = try await Summarizer.generate(
                                    text: String(transcriber.completeTranscript.characters),
                                    style: .standard
                                )
                            } catch {
                                print("Erreur: \(error)")
                            }
                        }
                    }
                    Text(summary)
                }
            }
            .padding()
        }
    }
}
```

