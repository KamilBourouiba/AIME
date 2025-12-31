# Documentation complète d'AIME

**Apple Intelligence Made Easy** par Kamil Bourouiba

## Table des matières

1. [Introduction](#introduction)
2. [Installation](#installation)
3. [Architecture](#architecture)
4. [Modules principaux](#modules-principaux)
5. [Configuration](#configuration)
6. [Gestion des erreurs](#gestion-des-erreurs)
7. [Logging et tokens](#logging-et-tokens)
8. [Exemples avancés](#exemples-avancés)

## Introduction

AIME est un package Swift complet qui simplifie l'intégration d'Apple Intelligence dans vos applications SwiftUI. Il offre une API simple et intuitive avec de nombreux paramètres optionnels pour personnaliser le comportement.

### Fonctionnalités principales

- 🎤 **Transcription vocale en temps réel** avec support multi-locale
- 💬 **Génération de texte intelligente** (Q&A, résumés, action items, timelines)
- 📊 **Analyse de documents** et traitement de texte
- 🔍 **Logging complet** avec suivi des tokens
- ⚙️ **Configuration flexible** avec paramètres optionnels
- 🛡️ **Gestion d'erreurs robuste** avec messages clairs

## Installation

### Swift Package Manager

Ajoutez AIME à votre projet Xcode :

1. File → Add Package Dependencies
2. Entrez l'URL du package
3. Sélectionnez la version souhaitée

Ou ajoutez-le directement dans votre `Package.swift` :

```swift
dependencies: [
    .package(url: "path/to/AIME", from: "1.0.0")
]
```

### Prérequis

- iOS 17.0+ / macOS 14.0+ / watchOS 10.0+ / tvOS 17.0+
- Swift 5.9+
- Xcode 15.0+

## Architecture

### Structure du package

```
AIME/
├── Sources/
│   └── AIME/
│       ├── AIME.swift                    # Point d'entrée
│       ├── Configuration/               # Configurations
│       │   └── AIMEConfiguration.swift
│       ├── Errors/                      # Gestion d'erreurs
│       │   └── AIMEError.swift
│       ├── Logging/                     # Système de logging
│       │   └── Logging.swift
│       ├── Transcription/               # Transcription vocale
│       │   └── Transcriber.swift
│       ├── Generation/                  # Génération de texte
│       │   ├── QuestionAnswerer.swift
│       │   ├── Summarizer.swift
│       │   ├── ActionItemsExtractor.swift
│       │   └── TimelineExtractor.swift
│       └── Helpers/                     # Utilitaires
│           ├── TextProcessor.swift
│           ├── ModelAvailability.swift
│           └── AudioHelpers.swift
└── Package.swift
```

## Modules principaux

### 1. Transcription vocale (`Transcriber`)

Le module de transcription permet d'enregistrer et transcrire la voix en temps réel.

#### Fonctionnalités

- Enregistrement audio avec transcription en temps réel
- Support multi-locale
- Transcription volatile et finalisée
- Pause/reprise de l'enregistrement
- Génération automatique de titre et image (optionnel)

#### Utilisation de base

```swift
let transcriber = Transcriber()

// Démarrer l'enregistrement
try await transcriber.startRecording(
    locale: .current,
    onTranscriptUpdate: { transcript in
        print("Nouvelle transcription: \(transcript)")
    }
)

// Arrêter l'enregistrement
try await transcriber.stopRecording()
```

#### Paramètres optionnels

- `locale`: Locale pour la transcription
- `autoGenerateTitle`: Générer un titre automatiquement
- `autoGenerateImage`: Générer une image automatiquement
- `onTranscriptUpdate`: Callback pour les mises à jour
- `onError`: Callback pour les erreurs

### 2. Question-Réponse (`QuestionAnswerer`)

Posez des questions sur un texte et obtenez des réponses intelligentes.

#### Utilisation de base

```swift
let answer = try await QuestionAnswerer.ask(
    question: "Quels sont les points principaux ?",
    context: documentText
)
```

#### Paramètres optionnels

- `useCase`: Cas d'utilisation du modèle (.general, .creative, etc.)
- `instructions`: Instructions personnalisées pour le modèle
- `includeCitation`: Inclure des citations dans la réponse
- `timeout`: Délai d'attente en secondes

#### Mode streaming

```swift
try await QuestionAnswerer.askStreaming(
    question: "Question",
    context: text,
    onUpdate: { partialAnswer in
        // Mettre à jour l'UI
    }
)
```

### 3. Résumés (`Summarizer`)

Générez des résumés de textes avec différents styles.

#### Styles disponibles

- `.concise`: Résumé très court (1-2 phrases)
- `.standard`: Résumé de longueur moyenne (2-3 paragraphes)
- `.detailed`: Résumé détaillé
- `.bulletPoints`: Résumé en puces

#### Utilisation

```swift
let summary = try await Summarizer.generate(
    text: longDocument,
    maxLength: 500,
    style: .standard
)
```

### 4. Action Items (`ActionItemsExtractor`)

Extrayez les action items d'un texte (réunions, documents, etc.).

#### Utilisation

```swift
let actionItems = try await ActionItemsExtractor.extract(
    text: meetingTranscript,
    maxItems: 10
)

for item in actionItems {
    print("- \(item.title)")
    if let priority = item.priority {
        print("  Priorité: \(priority)")
    }
}
```

### 5. Timeline (`TimelineExtractor`)

Extrayez les timelines et jalons de projet d'un texte.

#### Utilisation

```swift
let timeline = try await TimelineExtractor.extract(
    text: projectMeetings
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

## Configuration

### Configuration globale

```swift
AIME.defaultConfiguration = AIMEConfiguration(
    languageModel: LanguageModelConfiguration(
        useCase: .general,
        guardrails: .permissiveContentTransformations,
        defaultInstructions: "Tu es un assistant utile..."
    ),
    logging: LoggingConfiguration(
        isEnabled: true,
        level: .info,
        logTokens: true,
        logErrors: true
    ),
    transcription: TranscriptionConfiguration(
        locale: .current,
        bufferSize: 4096
    ),
    recording: RecordingConfiguration(
        saveToDisk: true
    )
)
```

### Configuration du modèle de langage

- `useCase`: Cas d'utilisation (.general, .creative, etc.)
- `guardrails`: Niveau de sécurité
- `defaultInstructions`: Instructions système par défaut
- `tools`: Outils disponibles pour le modèle

### Configuration du logging

- `isEnabled`: Activer/désactiver le logging
- `level`: Niveau de logging (.debug, .info, .warning, .error, .critical)
- `logTokens`: Logger l'utilisation des tokens
- `logErrors`: Logger les erreurs
- `logPerformance`: Logger les performances
- `customLogger`: Callback personnalisé

### Configuration de la transcription

- `locale`: Locale pour la transcription
- `transcriptionOptions`: Options de transcription
- `reportingOptions`: Options de reporting
- `attributeOptions`: Options d'attributs
- `bufferSize`: Taille du buffer audio

### Configuration de l'enregistrement

- `audioFormat`: Format audio souhaité
- `audioSessionCategory`: Catégorie de session audio
- `audioSessionMode`: Mode de session audio
- `saveToDisk`: Sauvegarder l'audio sur disque
- `saveURL`: URL pour sauvegarder l'audio

## Gestion des erreurs

### Types d'erreurs

AIME définit plusieurs types d'erreurs dans `AIMEError` :

#### Erreurs de transcription
- `.transcriptionNotAuthorized`
- `.transcriptionSetupFailed`
- `.transcriptionLocaleNotSupported`
- `.transcriptionModelDownloadFailed`
- `.transcriptionNoInternetConnection`
- `.transcriptionInvalidAudioFormat`

#### Erreurs d'enregistrement
- `.recordingNotAuthorized`
- `.recordingSetupFailed`
- `.recordingStartFailed`
- `.recordingStopFailed`

#### Erreurs de génération
- `.generationModelNotAvailable`
- `.generationGuardrailViolation`
- `.generationInvalidInput`
- `.generationTimeout`
- `.generationCancelled`

### Gestion des erreurs

```swift
do {
    let result = try await QuestionAnswerer.ask(...)
} catch AIMEError.generationModelNotAvailable {
    // Apple Intelligence n'est pas disponible
    showAlert("Fonctionnalité non disponible")
} catch AIMEError.transcriptionNotAuthorized {
    // Demander les autorisations
    showSettingsAlert()
} catch let error as AIMEError {
    // Autres erreurs AIME
    print("Erreur: \(error.localizedDescription)")
    if let suggestion = error.recoverySuggestion {
        print("Suggestion: \(suggestion)")
    }
} catch {
    // Erreurs inconnues
    print("Erreur inconnue: \(error)")
}
```

## Logging et tokens

### Système de logging

AIME inclut un système de logging complet avec plusieurs niveaux :

```swift
AIMELogger.shared.debug("Message de debug")
AIMELogger.shared.info("Message d'information")
AIMELogger.shared.warning("Avertissement")
AIMELogger.shared.error("Erreur", error: someError)
AIMELogger.shared.critical("Erreur critique", error: criticalError)
```

### Suivi des tokens

Le système de suivi des tokens permet de monitorer l'utilisation :

```swift
// Obtenir l'utilisation totale
let usage = TokenTracker.shared.getTotalUsage()
print("Total tokens: \(usage.totalTokens)")
print("  Input: \(usage.inputTokens)")
print("  Output: \(usage.outputTokens)")

// Obtenir l'historique
let history = TokenTracker.shared.getUsageHistory()

// Réinitialiser
TokenTracker.shared.reset()
```

## Exemples avancés

### Application complète de transcription

Voir `EXAMPLES.md` pour des exemples complets d'utilisation.

### Intégration avec SwiftUI

```swift
@StateObject private var transcriber = Transcriber()

var body: some View {
    VStack {
        Text(transcriber.completeTranscript)
        
        if transcriber.isRecording {
            Button("Arrêter") {
                Task { try? await transcriber.stopRecording() }
            }
        } else {
            Button("Démarrer") {
                Task { try? await transcriber.startRecording() }
            }
        }
    }
}
```

### Traitement par lots

```swift
let documents = [...]
var summaries: [String] = []

for document in documents {
    let summary = try await Summarizer.generate(
        text: document,
        style: .concise
    )
    summaries.append(summary)
}
```

## Support et contribution

Pour toute question ou suggestion, veuillez ouvrir une issue sur le dépôt GitHub.

## Licence

Voir le fichier `LICENSE.txt` pour plus d'informations.

