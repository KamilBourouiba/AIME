/*
 Builder pour créer facilement des prompts personnalisés
 */

import Foundation

/// Builder pour créer des prompts de manière simple et lisible
public struct PromptBuilder {
    private var components: [String] = []
    private var instructions: [String] = []
    
    public init() {}
    
    /// Ajouter une section au prompt
    /// - Parameters:
    ///   - title: Titre de la section
    ///   - content: Contenu de la section
    /// - Returns: Le builder pour chaînage
    @discardableResult
    public mutating func addSection(title: String, content: String) -> PromptBuilder {
        components.append("## \(title)\n\(content)")
        return self
    }
    
    /// Ajouter du texte simple
    /// - Parameter text: Le texte à ajouter
    /// - Returns: Le builder pour chaînage
    @discardableResult
    public mutating func addText(_ text: String) -> PromptBuilder {
        components.append(text)
        return self
    }
    
    /// Ajouter une question
    /// - Parameter question: La question
    /// - Returns: Le builder pour chaînage
    @discardableResult
    public mutating func addQuestion(_ question: String) -> PromptBuilder {
        components.append("Question: \(question)")
        return self
    }
    
    /// Ajouter un contexte
    /// - Parameter context: Le contexte
    /// - Returns: Le builder pour chaînage
    @discardableResult
    public mutating func addContext(_ context: String) -> PromptBuilder {
        components.append("Contexte:\n\(context)")
        return self
    }
    
    /// Ajouter une instruction
    /// - Parameter instruction: L'instruction
    /// - Returns: Le builder pour chaînage
    @discardableResult
    public mutating func addInstruction(_ instruction: String) -> PromptBuilder {
        instructions.append(instruction)
        return self
    }
    
    /// Construire le prompt final
    /// - Returns: Le prompt complet
    public func build() -> String {
        var prompt = components.joined(separator: "\n\n")
        
        if !instructions.isEmpty {
            prompt += "\n\n## Instructions\n" + instructions.joined(separator: "\n")
        }
        
        return prompt
    }
}

/// Templates de prompts prédéfinis pour faciliter la création
public struct PromptTemplates {
    
    /// Template pour question-réponse
    /// - Parameters:
    ///   - question: La question
    ///   - context: Le contexte
    /// - Returns: Un builder pré-configuré
    public static func questionAnswer(question: String, context: String) -> PromptBuilder {
        var builder = PromptBuilder()
        builder.addQuestion(question)
        builder.addContext(context)
        builder.addInstruction("Réponds de manière claire et concise en te basant uniquement sur le contexte fourni.")
        return builder
    }
    
    /// Template pour résumé
    /// - Parameters:
    ///   - text: Le texte à résumer
    ///   - style: Style de résumé (optionnel)
    /// - Returns: Un builder pré-configuré
    public static func summary(text: String, style: String? = nil) -> PromptBuilder {
        var builder = PromptBuilder()
        builder.addSection(title: "Texte à résumer", content: text)
        if let style = style {
            builder.addInstruction("Style de résumé: \(style)")
        }
        builder.addInstruction("Crée un résumé concis et informatif.")
        return builder
    }
    
    /// Template pour extraction d'action items
    /// - Parameter text: Le texte à analyser
    /// - Returns: Un builder pré-configuré
    public static func actionItems(text: String) -> PromptBuilder {
        var builder = PromptBuilder()
        builder.addSection(title: "Texte à analyser", content: text)
        builder.addInstruction("Extrais tous les action items (tâches, actions à prendre) du texte.")
        builder.addInstruction("Retourne une liste claire et structurée.")
        return builder
    }
    
    /// Template pour timeline
    /// - Parameter text: Le texte à analyser
    /// - Returns: Un builder pré-configuré
    public static func timeline(text: String) -> PromptBuilder {
        var builder = PromptBuilder()
        builder.addSection(title: "Texte à analyser", content: text)
        builder.addInstruction("Extrais tous les jalons, dates importantes et événements pour créer une timeline.")
        builder.addInstruction("Inclus les dates, les personnes responsables et les statuts si mentionnés.")
        return builder
    }
}

