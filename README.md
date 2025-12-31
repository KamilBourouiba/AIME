# AIME - Apple Intelligence Made Easy

**Par Kamil Bourouiba**

Un package Swift complet et facile à utiliser pour intégrer Apple Intelligence dans vos applications SwiftUI. Conçu pour les développeurs débutants avec une API simple et intuitive.

## 🚀 Fonctionnalités

- 🎤 **Transcription vocale en temps réel** - Enregistrez et transcrivez la voix avec des paramètres configurables
- 💬 **Génération de texte intelligente** - Posez des questions, générez des résumés, extraire des action items
- 📊 **Analyse de documents** - Traitez des documents PDF, texte et images
- 🔍 **Logging complet** - Suivez les tokens utilisés, les erreurs et les performances
- ⚙️ **Configuration flexible** - Beaucoup de paramètres optionnels pour personnaliser le comportement

## 📦 Installation

Ajoutez AIME à votre projet Swift Package Manager :

```swift
dependencies: [
    .package(url: "path/to/AIME", from: "1.0.0")
]
```

## 🎯 Utilisation rapide

### Transcription vocale

```swift
import AIME

let transcriber = AIME.Transcriber()
try await transcriber.startRecording(
    locale: .current,
    onTranscriptUpdate: { transcript in
        print("Transcription: \(transcript)")
    }
)
```

### Poser une question

```swift
let answer = try await AIME.QuestionAnswerer.ask(
    question: "Quels sont les points principaux ?",
    context: documentText
)
print(answer)
```

### Générer un résumé

```swift
let summary = try await AIME.Summarizer.generate(
    text: longDocument,
    maxLength: 500,
    style: .concise
)
```

## 📚 Documentation complète

Voir la documentation dans le dossier `Documentation/` pour plus d'exemples et de détails.

## 📄 Licence

Voir le fichier LICENSE pour plus d'informations.

