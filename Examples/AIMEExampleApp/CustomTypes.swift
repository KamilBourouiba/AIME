/*
 Exemples de types Generable personnalisés que vous créez dans votre code
 */

import Foundation
import FoundationModels
import AIME

// MARK: - Vos Types Generable Personnalisés

/// Exemple de type pour question-réponse personnalisé
@available(iOS 26.0, macOS 26.0, watchOS 26.0, tvOS 26.0, *)
@Generable
struct MyQuestionAnswer {
    @Guide(description: "La réponse à la question")
    var answer: String
    
    @Guide(description: "Une citation du contexte source")
    var citation: String?
    
    @Guide(description: "Niveau de confiance (0-100)")
    var confidence: Int?
    
    @Guide(description: "Indique si les informations sont insuffisantes")
    var insufficientInformation: Bool
}

/// Exemple de type pour résumé personnalisé
@available(iOS 26.0, macOS 26.0, watchOS 26.0, tvOS 26.0, *)
@Generable
struct MySummary {
    @Guide(description: "Le résumé du texte")
    var summary: String
    
    @Guide(description: "Les points clés (maximum 5)")
    var keyPoints: [String]?
    
    @Guide(description: "Le sentiment général")
    var sentiment: String?
}

/// Exemple de type pour action items personnalisé
@available(iOS 26.0, macOS 26.0, watchOS 26.0, tvOS 26.0, *)
@Generable
struct MyActionItems {
    @Guide(description: "Liste des action items")
    var actionItems: [ActionItemData]
}

@available(iOS 26.0, macOS 26.0, watchOS 26.0, tvOS 26.0, *)
@Generable
struct ActionItemData {
    @Guide(description: "Titre de la tâche")
    var title: String
    
    @Guide(description: "Personne responsable")
    var assignee: String?
    
    @Guide(description: "Date d'échéance")
    var dueDate: String?
    
    @Guide(description: "Priorité (haute, moyenne, basse)")
    var priority: String?
}

/// Exemple de type pour timeline personnalisé
@available(iOS 26.0, macOS 26.0, watchOS 26.0, tvOS 26.0, *)
@Generable
struct MyTimeline {
    @Guide(description: "Les items de la timeline")
    var items: [TimelineItemData]?
    
    @Guide(description: "Notes d'extraction")
    var notes: String?
}

@available(iOS 26.0, macOS 26.0, watchOS 26.0, tvOS 26.0, *)
@Generable
struct TimelineItemData {
    @Guide(description: "Titre de l'item")
    var title: String
    
    @Guide(description: "Date ou période")
    var date: String
    
    @Guide(description: "Personne responsable")
    var owner: String?
    
    @Guide(description: "Statut")
    var status: String?
    
    @Guide(description: "Priorité")
    var priority: String?
}

