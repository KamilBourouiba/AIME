/*
 AIME - Apple Intelligence Made Easy
 API simplifiée style OpenAI pour FoundationModels
 */

import Foundation
import FoundationModels

/// API principale d'AIME - Style OpenAI simplifié
@available(iOS 26.0, macOS 26.0, watchOS 26.0, tvOS 26.0, *)
public struct AIME {
    
    /// Créer un client AIME
    /// - Parameters:
    ///   - useCase: Cas d'utilisation du modèle
    ///   - systemPrompt: Prompt système (optionnel)
    /// - Returns: Un client AIME configuré
    public static func client(
        useCase: SystemLanguageModel.UseCase = .general,
        systemPrompt: String? = nil
    ) throws -> AIMEClient {
        return try AIMEClient(useCase: useCase, systemPrompt: systemPrompt)
    }
}

/// Client AIME pour faire des appels au modèle
@available(iOS 26.0, macOS 26.0, watchOS 26.0, tvOS 26.0, *)
public class AIMEClient {
    private let session: LanguageModelSession
    
    /// Initialiser le client
    /// - Parameters:
    ///   - useCase: Cas d'utilisation
    ///   - systemPrompt: Prompt système personnalisé
    public init(
        useCase: SystemLanguageModel.UseCase = .general,
        systemPrompt: String? = nil
    ) throws {
        let model = SystemLanguageModel(useCase: useCase)
        
        guard model.isAvailable else {
            throw AIMEError.generationModelNotAvailable
        }
        
        let instructions = systemPrompt ?? "Tu es un assistant utile."
        self.session = LanguageModelSession(model: model, instructions: instructions)
    }
    
    /// Générer une réponse avec votre type Generable
    /// - Parameters:
    ///   - prompt: Votre prompt
    ///   - generating: Le type Generable que vous voulez recevoir
    /// - Returns: La réponse générée
    public func generate<T: Generable>(
        prompt: String,
        generating: T.Type
    ) async throws -> T {
        let response = try await session.respond(to: prompt, generating: T.self)
        
        // Enregistrer les tokens
        let inputTokens = TextProcessor.estimateTokenCount(prompt)
        let outputText = String(describing: response.content)
        let outputTokens = TextProcessor.estimateTokenCount(outputText)
        TokenTracker.shared.recordUsage(inputTokens: inputTokens, outputTokens: outputTokens)
        
        return response.content
    }
    
    /// Générer en streaming
    /// - Parameters:
    ///   - prompt: Votre prompt
    ///   - generating: Le type Generable
    ///   - onUpdate: Callback appelé à chaque mise à jour
    /// - Returns: La réponse finale
    public func generateStreaming<T: Generable>(
        prompt: String,
        generating: T.Type,
        onUpdate: @escaping (T.PartiallyGenerated) -> Void
    ) async throws -> T {
        let stream = session.streamResponse(to: prompt, generating: T.self)
        let inputTokens = TextProcessor.estimateTokenCount(prompt)
        var lastOutputTokens = 0
        
        for try await partialResponse in stream {
            let partialContent = partialResponse.content
            onUpdate(partialContent)
            
            // Enregistrer les tokens
            let outputText = String(describing: partialContent)
            let currentOutputTokens = TextProcessor.estimateTokenCount(outputText)
            
            if currentOutputTokens != lastOutputTokens {
                TokenTracker.shared.recordUsage(inputTokens: inputTokens, outputTokens: currentOutputTokens)
                lastOutputTokens = currentOutputTokens
            }
        }
        
        // Obtenir la réponse finale
        let finalResponse = try await session.respond(to: prompt, generating: T.self)
        return finalResponse.content
    }
}

