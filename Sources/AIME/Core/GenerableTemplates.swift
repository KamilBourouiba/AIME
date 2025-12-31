/*
 Templates de structures Generable que l'utilisateur peut copier et modifier
 Ces sont des exemples que l'utilisateur peut utiliser comme point de départ
 */

import Foundation
import FoundationModels

/// Exemples de structures Generable que vous pouvez copier dans votre code
/// et modifier selon vos besoins
@available(iOS 26.0, macOS 26.0, watchOS 26.0, tvOS 26.0, *)
public enum GenerableTemplates {
    
    /// Exemple de structure pour question-réponse
    /// Copiez cette structure dans votre code et modifiez-la selon vos besoins
    public struct QuestionAnswerExample {
        @Guide(description: "La réponse à la question")
        public var answer: String
        
        @Guide(description: "Une citation du contexte source")
        public var citation: String?
        
        @Guide(description: "Indique si les informations sont insuffisantes")
        public var insufficientInformation: Bool
    }
    
    /// Exemple de structure pour résumé
    public struct SummaryExample {
        @Guide(description: "Le résumé du texte")
        public var summary: String
        
        @Guide(description: "Les points clés")
        public var keyPoints: [String]?
    }
    
    /// Exemple de structure pour action items
    public struct ActionItemsExample {
        @Guide(description: "Liste des action items")
        public var actionItems: [String]
        
        @Guide(description: "Priorité de chaque item")
        public var priorities: [String]?
    }
    
    /// Exemple de structure pour timeline
    public struct TimelineExample {
        @Guide(description: "Les items de la timeline")
        public var items: [TimelineItemExample]?
        
        @Guide(description: "Notes d'extraction")
        public var notes: String?
    }
    
    public struct TimelineItemExample {
        @Guide(description: "Titre de l'item")
        public var title: String
        
        @Guide(description: "Date ou période")
        public var date: String
        
        @Guide(description: "Personne responsable")
        public var owner: String?
        
        @Guide(description: "Statut")
        public var status: String?
    }
}

/// Guide pour créer vos propres structures Generable
/// 
/// Exemple d'utilisation :
/// ```swift
/// @Generable
/// struct MyCustomResponse {
///     @Guide(description: "Description de ce que vous voulez")
///     var myField: String
///     
///     @Guide(description: "Un champ optionnel")
///     var optionalField: String?
/// }
/// 
/// // Utilisation
/// let response = try await LanguageModelHelper.generate<MyCustomResponse>(
///     prompt: "Votre prompt ici"
/// )
/// ```
public struct GenerableGuide {
    /// Instructions pour créer vos propres types Generable
    public static let instructions = """
    Pour créer vos propres structures Generable :
    
    1. Créez une structure avec @Generable
    2. Ajoutez des propriétés avec @Guide pour décrire ce que vous voulez
    3. Utilisez LanguageModelHelper.generate<T>() avec votre type
    
    Exemple :
    @Generable
    struct MyResponse {
        @Guide(description: "La réponse")
        var answer: String
    }
    
    let result = try await LanguageModelHelper.generate<MyResponse>(
        prompt: "Votre prompt"
    )
    """
}

