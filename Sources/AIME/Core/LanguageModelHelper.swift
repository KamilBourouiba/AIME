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
        // Estimer les tokens de sortie en sérialisant la réponse
        let encoder = JSONEncoder()
        if let jsonData = try? encoder.encode(response.content),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            let outputTokens = TextProcessor.estimateTokenCount(jsonString)
            TokenTracker.shared.recordUsage(inputTokens: inputTokens, outputTokens: outputTokens)
        } else {
            // Fallback: estimation basée sur la description
            let outputText = String(describing: response.content)
            let outputTokens = TextProcessor.estimateTokenCount(outputText)
            TokenTracker.shared.recordUsage(inputTokens: inputTokens, outputTokens: outputTokens)
        }
        
        return response.content
    }
    
    /// Générer une réponse en streaming avec votre propre type Generable
    /// - Parameters:
    ///   - prompt: Le prompt à envoyer
    ///   - session: La session de modèle (optionnel)
    ///   - useCase: Cas d'utilisation (si session non fournie)
    ///   - instructions: Instructions système (si session non fournie)
    ///   - onUpdate: Callback appelé à chaque mise à jour
    /// - Returns: La réponse finale de type T
    public static func generateStreaming<T: Generable>(
        prompt: String,
        session: LanguageModelSession? = nil,
        useCase: SystemLanguageModel.UseCase = .general,
        instructions: String? = nil,
        onUpdate: @escaping (T) -> Void
    ) async throws -> T {
        let finalSession: LanguageModelSession
        if let session = session {
            finalSession = session
        } else {
            finalSession = try createSession(useCase: useCase, instructions: instructions)
        }
        
        let stream = finalSession.streamResponse(to: prompt, generating: T.self)
        let inputTokens = TextProcessor.estimateTokenCount(prompt)
        var lastResponse: T?
        var lastOutputTokens = 0
        
        for try await partialResponse in stream {
            lastResponse = partialResponse.content
            onUpdate(partialResponse.content)
            
            // Enregistrer les tokens
            let encoder = JSONEncoder()
            var currentOutputTokens = 0
            if let jsonData = try? encoder.encode(partialResponse.content),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                currentOutputTokens = TextProcessor.estimateTokenCount(jsonString)
            } else {
                let outputText = String(describing: partialResponse.content)
                currentOutputTokens = TextProcessor.estimateTokenCount(outputText)
            }
            
            if currentOutputTokens != lastOutputTokens {
                TokenTracker.shared.recordUsage(inputTokens: inputTokens, outputTokens: currentOutputTokens)
                lastOutputTokens = currentOutputTokens
            }
        }
        
        guard let finalResponse = lastResponse else {
            throw AIMEError.generationUnknownError(NSError(domain: "AIME", code: -1))
        }
        
        return finalResponse
    }
}

