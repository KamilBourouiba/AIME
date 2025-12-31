/*
 Vue principale utilisant la nouvelle architecture AIME v2.0
 Avec vos propres types Generable
 */

import SwiftUI
import AIME
import FoundationModels

struct NewContentView: View {
    @StateObject private var transcriber = Transcriber()
    @State private var question = ""
    @State private var answer: MyQuestionAnswer?
    @State private var summary: MySummary?
    @State private var actionItems: MyActionItems?
    @State private var timeline: MyTimeline?
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
    @State private var customInstructions: String = ""
    @State private var showPromptEditor = false
    @State private var showTokenLogs = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Section Logs de Tokens
                    tokenLogsMiniSection
                    
                    Divider()
                    
                    // Section Question-Réponse avec votre type personnalisé
                    questionAnswerSection
                    
                    Divider()
                    
                    // Section Résumé avec votre type personnalisé
                    summarySection
                    
                    Divider()
                    
                    // Section Action Items avec votre type personnalisé
                    actionItemsSection
                    
                    Divider()
                    
                    // Section Timeline avec votre type personnalisé
                    timelineSection
                }
                .padding()
            }
            .navigationTitle("AIME v2.0 - Personnalisé")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: {
                        showTokenLogs.toggle()
                    }) {
                        Image(systemName: "chart.bar")
                    }
                    
                    Button(action: {
                        showPromptEditor.toggle()
                    }) {
                        Image(systemName: "pencil")
                    }
                }
            }
            .sheet(isPresented: $showPromptEditor) {
                NavigationView {
                    PromptEditorView(testText: $testText, customInstructions: $customInstructions)
                        .navigationTitle("Éditeur de Prompt")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("Fermer") {
                                    showPromptEditor = false
                                }
                            }
                        }
                }
            }
            .sheet(isPresented: $showTokenLogs) {
                NavigationView {
                    TokenLogsView()
                        .navigationTitle("Logs de Tokens")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("Fermer") {
                                    showTokenLogs = false
                                }
                            }
                        }
                }
            }
        }
    }
    
    // MARK: - Sections
    
    private var tokenLogsMiniSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("📊 Tokens")
                    .font(.headline)
                let usage = TokenTracker.shared.getTotalUsage()
                Text("Total: \(usage.totalTokens) (In: \(usage.inputTokens), Out: \(usage.outputTokens))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: {
                showTokenLogs = true
            }) {
                Text("Voir détails")
                    .font(.caption)
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
        .padding()
        .background(Color.blue.opacity(0.05))
        .cornerRadius(10)
    }
    
    private var questionAnswerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("❓ Question-Réponse (Personnalisé)")
                    .font(.headline)
                
                Spacer()
                
                Button(action: {
                    showPromptEditor = true
                }) {
                    Image(systemName: "pencil.circle")
                        .font(.caption)
                }
                .buttonStyle(.plain)
            }
            
            TextField("Posez une question", text: $question)
                .textFieldStyle(.roundedBorder)
            
            Button("Poser la question") {
                Task {
                    do {
                        // Créer votre prompt avec PromptBuilder
                        var promptBuilder = PromptBuilder()
                        promptBuilder.addQuestion(question)
                        promptBuilder.addContext(testText)
                        if !customInstructions.isEmpty {
                            promptBuilder.addInstruction(customInstructions)
                        }
                        let prompt = promptBuilder.build()
                        
                        // Générer avec votre type personnalisé
                        answer = try await LanguageModelHelper.generate<MyQuestionAnswer>(
                            prompt: prompt,
                            instructions: customInstructions.isEmpty ? nil : customInstructions
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
                    Text("Réponse:")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text(answer.answer)
                    
                    if let citation = answer.citation {
                        Text("Citation: \(citation)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if let confidence = answer.confidence {
                        Text("Confiance: \(confidence)%")
                            .font(.caption)
                            .foregroundColor(.blue)
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
            Text("📝 Résumé (Personnalisé)")
                .font(.headline)
            
            Button("Générer un résumé") {
                Task {
                    do {
                        // Utiliser un template de prompt
                        let prompt = PromptTemplates.summary(
                            text: testText,
                            style: "professionnel"
                        ).build()
                        
                        summary = try await LanguageModelHelper.generate<MySummary>(
                            prompt: prompt,
                            instructions: customInstructions.isEmpty ? nil : customInstructions
                        )
                    } catch {
                        print("Erreur: \(error.localizedDescription)")
                    }
                }
            }
            .buttonStyle(.bordered)
            
            if let summary = summary {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Résumé:")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text(summary.summary)
                    
                    if let keyPoints = summary.keyPoints, !keyPoints.isEmpty {
                        Text("Points clés:")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        ForEach(keyPoints, id: \.self) { point in
                            Text("• \(point)")
                        }
                    }
                    
                    if let sentiment = summary.sentiment {
                        Text("Sentiment: \(sentiment)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.green.opacity(0.1))
                .cornerRadius(8)
            }
        }
    }
    
    private var actionItemsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("✅ Action Items (Personnalisé)")
                .font(.headline)
            
            Button("Extraire les action items") {
                Task {
                    do {
                        let prompt = PromptTemplates.actionItems(text: testText).build()
                        
                        actionItems = try await LanguageModelHelper.generate<MyActionItems>(
                            prompt: prompt,
                            instructions: customInstructions.isEmpty ? nil : customInstructions
                        )
                    } catch {
                        print("Erreur: \(error.localizedDescription)")
                    }
                }
            }
            .buttonStyle(.bordered)
            
            if let actionItems = actionItems {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(Array(actionItems.actionItems.enumerated()), id: \.offset) { index, item in
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(index + 1). \(item.title)")
                                .fontWeight(.semibold)
                            
                            if let assignee = item.assignee {
                                Text("👤 \(assignee)")
                                    .font(.caption)
                            }
                            
                            if let dueDate = item.dueDate {
                                Text("📅 \(dueDate)")
                                    .font(.caption)
                            }
                            
                            if let priority = item.priority {
                                Text("🎯 \(priority)")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            }
                        }
                        .padding(.vertical, 4)
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
            Text("📅 Timeline (Personnalisé)")
                .font(.headline)
            
            Button("Extraire la timeline") {
                Task {
                    do {
                        let prompt = PromptTemplates.timeline(text: testText).build()
                        
                        timeline = try await LanguageModelHelper.generate<MyTimeline>(
                            prompt: prompt,
                            instructions: customInstructions.isEmpty ? nil : customInstructions
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
                            
                            if let priority = item.priority {
                                Text("🎯 \(priority)")
                                    .font(.caption)
                                    .foregroundColor(.purple)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.purple.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    if let notes = timeline.notes {
                        Text("Notes: \(notes)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top)
                    }
                }
            }
        }
    }
}

#Preview {
    NewContentView()
}

