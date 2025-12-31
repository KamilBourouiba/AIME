/*
 Helper principal pour utiliser les Language Models avec des prompts personnalisables
 */

import Foundation
import FoundationModels

/// Helper pour utiliser les Language Models avec vos propres types Generable
@available(iOS 26.0, macOS 26.0, watchOS 26.0, tvOS 26.0, *)
public struct LanguageModelHelper {
    
    /// Créer une session de modèle de langage
    /// - Parameters:
    ///   - useCase: Cas d'utilisation (par défaut: .general)
    ///   - instructions: Instructions système personnalisées
    /// - Returns: Une session configurée
    public static func createSession(
        useCase: SystemLanguageModel.UseCase = .general,
        instructions: String? = nil
    ) throws -> LanguageModelSession {
        let model = SystemLanguageModel(useCase: useCase)
        
        guard model.isAvailable else {
            throw AIMEError.generationModelNotAvailable
        }
        
        let defaultInstructions = instructions ?? """
        Tu es un assistant utile qui répond aux questions de manière claire et concise.
        """
        
        return LanguageModelSession(model: model, instructions: defaultInstructions)
    }
    
    /// Générer une réponse avec votre propre type Generable
    /// - Parameters:
    ///   - prompt: Le prompt à envoyer
    ///   - session: La session de modèle (optionnel, créera une nouvelle si non fournie)
    ///   - useCase: Cas d'utilisation (si session non fournie)
    ///   - instructions: Instructions système (si session non fournie)
    /// - Returns: La réponse générée de type T
    public static func generate<T: Generable>(
        prompt: String,
        session: LanguageModelSession? = nil,
        useCase: SystemLanguageModel.UseCase = .general,
        instructions: String? = nil
    ) async throws -> T {
        let finalSession: LanguageModelSession
        if let session = session {
            finalSession = session
        } else {
            finalSession = try createSession(useCase: useCase, instructions: instructions)
        }
        
        let response = try await finalSession.respond(to: prompt, generating: T.self)
        
        // Enregistrer les tokens
        let inputTokens = TextProcessor.estimateTokenCount(prompt)
        // Estimer les tokens de sortie basé sur la description
        let outputText = String(describing: response.content)
        let outputTokens = TextProcessor.estimateTokenCount(outputText)
        TokenTracker.shared.recordUsage(inputTokens: inputTokens, outputTokens: outputTokens)
        
        return response.content
    }
    
    /// Générer une réponse en streaming avec votre propre type Generable
    /// - Parameters:
    ///   - prompt: Le prompt à envoyer
    ///   - session: La session de modèle (optionnel)
    ///   - useCase: Cas d'utilisation (si session non fournie)
    ///   - instructions: Instructions système (si session non fournie)
    ///   - onUpdate: Callback appelé à chaque mise à jour avec le contenu partiel
    /// - Returns: La réponse finale de type T
    /// 
    /// Note: Le callback reçoit `T.PartiallyGenerated` qui peut être utilisé comme `T` dans la plupart des cas.
    /// Pour obtenir le `T` final complet, cette méthode fait un appel final avec `respond()`.
    public static func generateStreaming<T: Generable>(
        prompt: String,
        session: LanguageModelSession? = nil,
        useCase: SystemLanguageModel.UseCase = .general,
        instructions: String? = nil,
        onUpdate: @escaping (T.PartiallyGenerated) -> Void
    ) async throws -> T {
        let finalSession: LanguageModelSession
        if let session = session {
            finalSession = session
        } else {
            finalSession = try createSession(useCase: useCase, instructions: instructions)
        }
        
        let stream = finalSession.streamResponse(to: prompt, generating: T.self)
        let inputTokens = TextProcessor.estimateTokenCount(prompt)
        var lastOutputTokens = 0
        
        for try await partialResponse in stream {
            let partialContent = partialResponse.content
            onUpdate(partialContent)
            
            // Enregistrer les tokens basé sur la description
            let outputText = String(describing: partialContent)
            let currentOutputTokens = TextProcessor.estimateTokenCount(outputText)
            
            if currentOutputTokens != lastOutputTokens {
                TokenTracker.shared.recordUsage(inputTokens: inputTokens, outputTokens: currentOutputTokens)
                lastOutputTokens = currentOutputTokens
            }
        }
        
        // Obtenir la réponse finale complète
        let finalResponse = try await finalSession.respond(to: prompt, generating: T.self)
        return finalResponse.content
    }
}

