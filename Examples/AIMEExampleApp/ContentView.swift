//
//  ContentView.swift
//  AIMEExampleApp
//
//  Created by Apprenant 122 on 12/31/25.
//

/*
 Vue principale de l'application d'exemple
 Utilise la nouvelle API simplifiée AIME v3.0
 */

import SwiftUI
import AIME
import FoundationModels

// MARK: - Vos Types Generable (dans votre code)

@Generable
struct Answer {
    @Guide(description: "La réponse à la question")
    var answer: String
    
    @Guide(description: "Une citation du contexte source")
    var citation: String?
}

@Generable
struct Summary {
    @Guide(description: "Le résumé du texte")
    var summary: String
}

@Generable
struct ActionItemsResponse {
    @Guide(description: "Liste des action items")
    var actionItems: [String]
}

@Generable
struct TimelineResponse {
    @Guide(description: "Les items de la timeline")
    var items: [TimelineItemResponse]?
}

@Generable
struct TimelineItemResponse {
    @Guide(description: "Titre de l'item")
    var title: String
    
    @Guide(description: "Date ou période")
    var date: String
    
    @Guide(description: "Personne responsable")
    var owner: String?
    
    @Guide(description: "Statut")
    var status: String?
}

// MARK: - Vue Principale

struct ContentView: View {
    @StateObject private var transcriber = Transcriber()
    @State private var question = ""
    @State private var answer: Answer?
    @State private var summary: Summary?
    @State private var actionItems: [String] = []
    @State private var timeline: TimelineResponse?
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
    
    // Vos prompts système - modifiez-les comme vous voulez !
    @State private var qaSystemPrompt = """
    Tu es un assistant utile qui répond aux questions en te basant UNIQUEMENT sur les informations fournies.
    Réponds de manière claire et concise.
    """
    
    @State private var summarySystemPrompt = """
    Tu es un assistant expert en résumé de texte.
    Crée des résumés concis et informatifs.
    """
    
    @State private var actionItemsSystemPrompt = """
    Tu es un assistant expert en extraction d'action items.
    Extrais tous les action items prioritaires des transcriptions de réunions.
    """
    
    @State private var timelineSystemPrompt = """
    Tu es un assistant expert en extraction de timeline.
    Extrais tous les jalons, dates importantes et événements pour créer une timeline.
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
            
            Text(String(transcriber.completeTranscript.characters).isEmpty ? "Aucune transcription" : String(transcriber.completeTranscript.characters))
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
                        // Nouvelle API simplifiée - Style OpenAI !
                        let client = try AIME.client(systemPrompt: qaSystemPrompt)
                        
                        // Votre prompt - écrivez-le comme vous voulez !
                        let prompt = """
                        Question: \(question)
                        
                        Voici toutes les informations que tu peux utiliser pour répondre:
                        \(testText)
                        """
                        
                        answer = try await client.generate(
                            prompt: prompt,
                            generating: Answer.self
                        )
                    } catch {
                        print("Erreur: \(error.localizedDescription)")
                    }
                }
            }
            .buttonStyle(.bordered)
            .disabled(question.isEmpty)
            
            if let answer = answer {
                VStack(alignment: .leading, spacing: 8) {
                    Text(answer.answer)
                    
                    if let citation = answer.citation {
                        Text("Citation: \(citation)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
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
                        // Nouvelle API simplifiée !
                        let client = try AIME.client(systemPrompt: summarySystemPrompt)
                        
                        // Votre prompt personnalisé
                        let prompt = """
                        Résume le texte suivant de manière concise et informative.
                        
                        Texte:
                        \(testText)
                        """
                        
                        summary = try await client.generate(
                            prompt: prompt,
                            generating: Summary.self
                        )
                    } catch {
                        print("Erreur: \(error.localizedDescription)")
                    }
                }
            }
            .buttonStyle(.bordered)
            
            if let summary = summary {
                Text(summary.summary)
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
                        // Nouvelle API simplifiée !
                        let client = try AIME.client(systemPrompt: actionItemsSystemPrompt)
                        
                        // Votre prompt - complètement personnalisé !
                        let prompt = """
                        Extrais tous les action items prioritaires du texte suivant.
                        Retourne une liste claire et structurée.
                        
                        Texte:
                        \(testText)
                        """
                        
                        let response = try await client.generate(
                            prompt: prompt,
                            generating: ActionItemsResponse.self
                        )
                        
                        actionItems = response.actionItems
                    } catch {
                        print("Erreur: \(error.localizedDescription)")
                    }
                }
            }
            .buttonStyle(.bordered)
            
            if !actionItems.isEmpty {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(Array(actionItems.enumerated()), id: \.offset) { index, item in
                        HStack {
                            Text("•")
                            Text(item)
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
                        // Nouvelle API simplifiée !
                        let client = try AIME.client(systemPrompt: timelineSystemPrompt)
                        
                        // Votre prompt personnalisé
                        let prompt = """
                        Crée une timeline à partir du texte suivant.
                        Inclus les dates, responsables et statuts si mentionnés.
                        
                        Texte:
                        \(testText)
                        """
                        
                        timeline = try await client.generate(
                            prompt: prompt,
                            generating: TimelineResponse.self
                        )
                    } catch {
                        print("Erreur: \(error.localizedDescription)")
                    }
                }
            }
            .buttonStyle(.bordered)
            
            if let timeline = timeline, let items = timeline.items {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(Array(items.enumerated()), id: \.offset) { index, item in
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
