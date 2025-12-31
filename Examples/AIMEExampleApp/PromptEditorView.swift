/*
 Vue pour éditer dynamiquement les prompts
 */

import SwiftUI
import AIME

struct PromptEditorView: View {
    @Binding var testText: String
    @Binding var customInstructions: String
    @State private var showCustomInstructions: Bool = false
    
    // Prompts prédéfinis
    private let predefinedPrompts: [(name: String, text: String)] = [
        ("Réunion Standard", """
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
        """),
        ("Réunion Technique", """
        Réunion technique - Architecture système
        
        Participants: Équipe développement
        
        Discussion:
        - Migration vers microservices
        - Optimisation de la base de données
        - Mise en place du CI/CD
        
        Décisions:
        - Utiliser Kubernetes pour l'orchestration
        - PostgreSQL comme base de données principale
        - GitHub Actions pour le CI/CD
        
        Actions:
        - Setup Kubernetes: Jean (échéance: 1er janvier)
        - Migration DB: Marie (échéance: 15 janvier)
        - Configuration CI/CD: Pierre (échéance: 10 janvier)
        """),
        ("Réunion Marketing", """
        Réunion marketing - Lancement produit
        
        Équipe: Marketing, Design, Product
        
        Points abordés:
        - Stratégie de lancement
        - Campagne publicitaire
        - Design des supports
        
        Budget alloué: 50 000€
        Date de lancement: 1er février 2025
        
        Tâches:
        - Création campagne: Sophie (15 janvier)
        - Design supports: Lucas (20 janvier)
        - Coordination: Emma (en cours)
        """),
        ("Réunion Client", """
        Appel client - Projet XYZ
        
        Client: ABC Corp
        Contact: M. Dupont
        
        Besoins identifiés:
        - Interface personnalisée
        - Intégration avec leur système
        - Support technique 24/7
        
        Prochaines étapes:
        - Devis à envoyer avant vendredi
        - Démo prévue le 20 décembre
        - Réponse attendue le 30 décembre
        """)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("✏️ Éditeur de Prompt")
                .font(.headline)
            
            // Sélection de prompt prédéfini
            VStack(alignment: .leading, spacing: 8) {
                Text("Prompts Prédéfinis")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(predefinedPrompts, id: \.name) { prompt in
                            Button(prompt.name) {
                                testText = prompt.text
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                        }
                    }
                }
            }
            
            // Éditeur de texte
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Texte du Prompt")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Button("Effacer") {
                        testText = ""
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
                
                TextEditor(text: $testText)
                    .frame(minHeight: 200)
                    .padding(8)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                
                Text("\(testText.count) caractères")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Instructions personnalisées (pour les appels API)
            VStack(alignment: .leading, spacing: 8) {
                Button(action: {
                    showCustomInstructions.toggle()
                }) {
                    HStack {
                        Text("Instructions Personnalisées")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Spacer()
                        Image(systemName: showCustomInstructions ? "chevron.down" : "chevron.right")
                    }
                }
                .buttonStyle(.plain)
                
                if showCustomInstructions {
                    TextEditor(text: $customInstructions)
                        .frame(minHeight: 100)
                        .padding(8)
                        .background(Color.blue.opacity(0.05))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                        )
                    
                    Text("Ces instructions seront utilisées pour les appels API (optionnel)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
}

#Preview {
    PromptEditorView(testText: .constant("Test prompt"), customInstructions: .constant(""))
        .padding()
}

