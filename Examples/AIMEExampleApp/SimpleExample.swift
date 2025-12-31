/*
 Exemple d'utilisation simplifiée - Style OpenAI
 */

import SwiftUI
import AIME
import FoundationModels

// MARK: - Vos Types Generable (dans votre code)

@Generable
struct Answer {
    @Guide(description: "La réponse")
    var answer: String
}

@Generable
struct Summary {
    @Guide(description: "Le résumé")
    var summary: String
    
    @Guide(description: "Points clés")
    var keyPoints: [String]?
}

@Generable
struct ActionItems {
    @Guide(description: "Liste des action items")
    var items: [String]
}

@Generable
struct Timeline {
    @Guide(description: "Items de timeline")
    var items: [TimelineItem]?
}

@Generable
struct TimelineItem {
    @Guide(description: "Titre")
    var title: String
    
    @Guide(description: "Date")
    var date: String
    
    @Guide(description: "Responsable")
    var owner: String?
}

// MARK: - Vue d'exemple

struct SimpleExampleView: View {
    @State private var answer: Answer?
    @State private var summary: Summary?
    @State private var actionItems: ActionItems?
    @State private var timeline: Timeline?
    
    // Votre texte - modifiez-le comme vous voulez !
    @State private var text = """
    Réunion du projet - 15 décembre 2024
    
    Participants: Alice, Bob, Charlie
    
    Points discutés:
    - Finalisation du design
    - Tests de performance
    - Documentation technique
    
    Actions:
    1. Alice doit finaliser les maquettes d'ici vendredi
    2. Bob va préparer les tests pour la semaine prochaine
    3. Charlie doit mettre à jour la documentation d'ici mercredi
    """
    
    // Votre prompt système - écrivez-le comme vous voulez !
    @State private var systemPrompt = """
    Tu es un assistant expert en analyse de réunions.
    Tu extrais les informations importantes de manière structurée.
    """
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Question-Réponse
                VStack(alignment: .leading) {
                    Text("Question-Réponse")
                        .font(.headline)
                    
                    Button("Générer") {
                        Task {
                            do {
                                // Style OpenAI - Simple et clair !
                                let client = try AIME.client(systemPrompt: systemPrompt)
                                
                                // Votre prompt - écrivez-le comme vous voulez !
                                let prompt = """
                                Question: Quelles sont les actions à prendre ?
                                
                                Contexte:
                                \(text)
                                """
                                
                                answer = try await client.generate(
                                    prompt: prompt,
                                    generating: Answer.self
                                )
                            } catch {
                                print("Erreur: \(error)")
                            }
                        }
                    }
                    
                    if let answer = answer {
                        Text(answer.answer)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                    }
                }
                
                // Résumé
                VStack(alignment: .leading) {
                    Text("Résumé")
                        .font(.headline)
                    
                    Button("Générer") {
                        Task {
                            do {
                                let client = try AIME.client(systemPrompt: systemPrompt)
                                
                                // Votre prompt personnalisé
                                let prompt = """
                                Résume le texte suivant en 3 phrases maximum.
                                Extrais aussi les 3 points clés les plus importants.
                                
                                Texte:
                                \(text)
                                """
                                
                                summary = try await client.generate(
                                    prompt: prompt,
                                    generating: Summary.self
                                )
                            } catch {
                                print("Erreur: \(error)")
                            }
                        }
                    }
                    
                    if let summary = summary {
                        Text(summary.summary)
                        if let keyPoints = summary.keyPoints {
                            ForEach(keyPoints, id: \.self) { point in
                                Text("• \(point)")
                            }
                        }
                    }
                }
                
                // Action Items
                VStack(alignment: .leading) {
                    Text("Action Items")
                        .font(.headline)
                    
                    Button("Extraire") {
                        Task {
                            do {
                                let client = try AIME.client(systemPrompt: systemPrompt)
                                
                                // Votre prompt - complètement personnalisé !
                                let prompt = """
                                Extrais tous les action items du texte suivant.
                                Retourne une liste claire et structurée.
                                
                                Texte:
                                \(text)
                                """
                                
                                actionItems = try await client.generate(
                                    prompt: prompt,
                                    generating: ActionItems.self
                                )
                            } catch {
                                print("Erreur: \(error)")
                            }
                        }
                    }
                    
                    if let actionItems = actionItems {
                        ForEach(actionItems.items, id: \.self) { item in
                            Text("• \(item)")
                        }
                    }
                }
                
                // Timeline
                VStack(alignment: .leading) {
                    Text("Timeline")
                        .font(.headline)
                    
                    Button("Extraire") {
                        Task {
                            do {
                                let client = try AIME.client(systemPrompt: systemPrompt)
                                
                                // Votre prompt personnalisé
                                let prompt = """
                                Crée une timeline à partir du texte suivant.
                                Inclus les dates, responsables et statuts si mentionnés.
                                
                                Texte:
                                \(text)
                                """
                                
                                timeline = try await client.generate(
                                    prompt: prompt,
                                    generating: Timeline.self
                                )
                            } catch {
                                print("Erreur: \(error)")
                            }
                        }
                    }
                    
                    if let timeline = timeline, let items = timeline.items {
                        ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                            VStack(alignment: .leading) {
                                Text(item.title)
                                Text("📅 \(item.date)")
                                if let owner = item.owner {
                                    Text("👤 \(owner)")
                                }
                            }
                            .padding()
                            .background(Color.purple.opacity(0.1))
                        }
                    }
                }
            }
            .padding()
        }
    }
}

#Preview {
    SimpleExampleView()
}

