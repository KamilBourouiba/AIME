/*
 Vue principale de l'application d'exemple
 */

import SwiftUI
import AIME

struct ContentView: View {
    @StateObject private var transcriber = Transcriber()
    @State private var question = ""
    @State private var answer = ""
    @State private var summary = ""
    @State private var actionItems: [ActionItem] = []
    @State private var timeline: Timeline?
    @State private var testText = """
    Réunion du projet - 15 décembre 2024
    
    Participants: Alice, Bob, Charlie
    
    Points discutés:
    - Finalisation du design de l'interface utilisateur
    - Tests de performance à effectuer avant la mise en production
    - Révision de la documentation technique
    
    Actions à prendre:
    1. Alice doit finaliser les maquettes d'ici vendredi
    2. Bob va préparer les tests de performance pour la semaine prochaine
    3. Charlie doit mettre à jour la documentation d'ici mercredi
    
    Prochaines étapes:
    - Réunion de suivi prévue le 20 décembre
    - Déploiement en production prévu pour le 1er janvier 2025
    """
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Section Transcription
                    transcriptionSection
                    
                    Divider()
                    
                    // Section Question-Réponse
                    questionAnswerSection
                    
                    Divider()
                    
                    // Section Résumé
                    summarySection
                    
                    Divider()
                    
                    // Section Action Items
                    actionItemsSection
                    
                    Divider()
                    
                    // Section Timeline
                    timelineSection
                }
                .padding()
            }
            .navigationTitle("AIME - Exemple")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Tester") {
                        runTests()
                    }
                }
            }
        }
    }
    
    // MARK: - Sections
    
    private var transcriptionSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("🎤 Transcription")
                .font(.headline)
            
            Text(transcriber.completeTranscript.isEmpty ? "Aucune transcription" : String(transcriber.completeTranscript.characters))
                .frame(minHeight: 100)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            
            HStack {
                if transcriber.isRecording {
                    Button("Arrêter") {
                        Task {
                            try? await transcriber.stopRecording()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                } else {
                    Button("Démarrer") {
                        Task {
                            do {
                                try await transcriber.startRecording(
                                    onTranscriptUpdate: { transcript in
                                        print("Transcription: \(transcript)")
                                    },
                                    onError: { error in
                                        print("Erreur: \(error.localizedDescription)")
                                    }
                                )
                            } catch {
                                print("Erreur lors du démarrage: \(error)")
                            }
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                
                if transcriber.isPaused {
                    Button("Reprendre") {
                        try? transcriber.resumeRecording()
                    }
                } else if transcriber.isRecording {
                    Button("Pause") {
                        transcriber.pauseRecording()
                    }
                }
            }
        }
    }
    
    private var questionAnswerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("❓ Question-Réponse")
                .font(.headline)
            
            TextField("Posez une question", text: $question)
                .textFieldStyle(.roundedBorder)
            
            Button("Poser la question") {
                Task {
                    do {
                        answer = try await QuestionAnswerer.ask(
                            question: question,
                            context: testText
                        )
                    } catch {
                        answer = "Erreur: \(error.localizedDescription)"
                    }
                }
            }
            .buttonStyle(.bordered)
            .disabled(question.isEmpty)
            
            if !answer.isEmpty {
                Text(answer)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
            }
        }
    }
    
    private var summarySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("📝 Résumé")
                .font(.headline)
            
            Button("Générer un résumé") {
                Task {
                    do {
                        summary = try await Summarizer.generate(
                            text: testText,
                            style: .standard
                        )
                    } catch {
                        summary = "Erreur: \(error.localizedDescription)"
                    }
                }
            }
            .buttonStyle(.bordered)
            
            if !summary.isEmpty {
                Text(summary)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(8)
            }
        }
    }
    
    private var actionItemsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("✅ Action Items")
                .font(.headline)
            
            Button("Extraire les action items") {
                Task {
                    do {
                        actionItems = try await ActionItemsExtractor.extract(
                            text: testText,
                            maxItems: 10
                        )
                    } catch {
                        print("Erreur: \(error.localizedDescription)")
                    }
                }
            }
            .buttonStyle(.bordered)
            
            if !actionItems.isEmpty {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(actionItems) { item in
                        HStack {
                            Text("•")
                            Text(item.title)
                            Spacer()
                        }
                        .padding(.vertical, 2)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(8)
            }
        }
    }
    
    private var timelineSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("📅 Timeline")
                .font(.headline)
            
            Button("Extraire la timeline") {
                Task {
                    do {
                        timeline = try await TimelineExtractor.extract(
                            text: testText
                        )
                    } catch {
                        print("Erreur: \(error.localizedDescription)")
                    }
                }
            }
            .buttonStyle(.bordered)
            
            if let timeline = timeline {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(timeline.items) { item in
                        VStack(alignment: .leading, spacing: 5) {
                            Text(item.title)
                                .font(.headline)
                            Text("📆 \(item.date)")
                            if let owner = item.owner {
                                Text("👤 \(owner)")
                            }
                            if let status = item.status {
                                Text("Status: \(status)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.purple.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
            }
        }
    }
    
    // MARK: - Tests
    
    private func runTests() {
        print("🧪 Exécution des tests...")
        
        // Test TextProcessor
        let chunks = TextProcessor.chunkText(testText)
        print("✅ TextProcessor.chunkText: \(chunks.count) chunks")
        
        let isEmpty = TextProcessor.isEmpty("")
        print("✅ TextProcessor.isEmpty: \(isEmpty)")
        
        // Test TokenTracker
        TokenTracker.shared.reset()
        TokenTracker.shared.recordUsage(inputTokens: 100, outputTokens: 50)
        let usage = TokenTracker.shared.getTotalUsage()
        print("✅ TokenTracker: \(usage.totalTokens) tokens")
        
        // Test ModelAvailability
        let isAvailable = ModelAvailability.isAvailable()
        print("✅ ModelAvailability.isAvailable: \(isAvailable)")
        
        print("✅ Tests terminés!")
    }
}

#Preview {
    ContentView()
}

