/*
 Module de question-réponse pour AIME
 */

import Foundation
import FoundationModels
import SwiftUI

// Types Generable pour QuestionAnswerer
@available(iOS 26.0, macOS 26.0, watchOS 26.0, tvOS 26.0, *)
@Generable
private struct QuestionAnswerResponse {
    @Guide(description: "Une citation exacte contenant la réponse depuis le matériel source")
    var citation: String?
    
    @Guide(description: "Une réponse brève à la question")
    var answer: String
    
    @Guide(description: "Indique si il n'était pas possible de répondre à la question")
    var insufficientInformation: Bool
}

/// Gestionnaire de questions-réponses simplifié
@available(iOS 26.0, macOS 26.0, watchOS 26.0, tvOS 26.0, *)
public struct QuestionAnswerer {
    
    /// Poser une question simple avec contexte
    /// - Parameters:
    ///   - question: La question à poser
    ///   - context: Le contexte (texte) sur lequel baser la réponse
    ///   - useCase: Cas d'utilisation du modèle (par défaut: .general)
    ///   - instructions: Instructions personnalisées pour le modèle (optionnel)
    ///   - includeCitation: Inclure des citations dans la réponse (par défaut: true)
    ///   - timeout: Délai d'attente en secondes (par défaut: 60)
    /// - Returns: La réponse générée
    public static func ask(
        question: String,
        context: String,
        useCase: SystemLanguageModel.UseCase = .general,
        instructions: String? = nil,
        includeCitation: Bool = true,
        timeout: TimeInterval = 60
    ) async throws -> String {
        guard !question.isEmpty else {
            throw AIMEError.generationInvalidInput
        }
        
        guard !context.isEmpty else {
            throw AIMEError.textProcessingEmptyInput
        }
        
        AIMELogger.shared.info("Génération de réponse", metadata: [
            "question": question,
            "contextLength": context.count
        ])
        
        let startTime = Date()
        
        do {
            let model = SystemLanguageModel(useCase: useCase)
            
            guard model.isAvailable else {
                throw AIMEError.generationModelNotAvailable
            }
            
            let defaultInstructions = """
            Tu es un assistant utile qui répond aux questions de l'utilisateur en te basant UNIQUEMENT sur les informations fournies.
            Important:
            - Réponds de manière claire et concise
            - Si la question n'est pas liée aux informations fournies, dis "Je ne peux pas répondre à cette question"
            - Utilise les informations fournies comme source de vérité
            """
            
            let finalInstructions = instructions ?? defaultInstructions
            
            let session = LanguageModelSession(
                model: model,
                instructions: finalInstructions
            )
            
            let prompt = """
            Question: \(question)
            
            Voici toutes les informations que tu peux utiliser pour répondre à la question:
            \(context)
            """
            
            let response = try await session.respond(
                to: prompt,
                generating: QuestionAnswerResponse.self
            )
            
            // Enregistrer l'utilisation des tokens
            let inputTokens = TextProcessor.estimateTokenCount(prompt)
            let outputText = response.content.answer ?? ""
            let outputTokens = TextProcessor.estimateTokenCount(outputText)
            TokenTracker.shared.recordUsage(inputTokens: inputTokens, outputTokens: outputTokens)
            
            let elapsedTime = Date().timeIntervalSince(startTime)
            
            if response.content.insufficientInformation == true {
                AIMELogger.shared.info("Réponse générée: informations insuffisantes", metadata: [
                    "elapsedTime": elapsedTime
                ])
                return "Je n'ai pas trouvé assez d'informations pour répondre à cette question."
            }
            
            var answer = response.content.answer ?? "Je ne peux pas répondre à cette question."
            
            if includeCitation, let citation = response.content.citation, !citation.isEmpty {
                answer += "\n\nCitation: \"\(citation)\""
            }
            
            AIMELogger.shared.info("Réponse générée avec succès", metadata: [
                "elapsedTime": elapsedTime,
                "answerLength": answer.count,
                "inputTokens": inputTokens,
                "outputTokens": outputTokens
            ])
            
            return answer
            
        } catch let error as LanguageModelSession.GenerationError {
            switch error {
            case .guardrailViolation:
                let aimeError = AIMEError.generationGuardrailViolation
                AIMELogger.shared.error("Violation des garde-fous", error: aimeError)
                throw aimeError
            default:
                let aimeError = AIMEError.generationUnknownError(error)
                AIMELogger.shared.error("Erreur de génération", error: aimeError)
                throw aimeError
            }
        } catch let error as AIMEError {
            throw error
        } catch {
            let aimeError = AIMEError.generationUnknownError(error)
            AIMELogger.shared.error("Erreur inconnue", error: aimeError)
            throw aimeError
        }
    }
    
    /// Poser une question avec streaming de la réponse
    /// - Parameters:
    ///   - question: La question à poser
    ///   - context: Le contexte (texte) sur lequel baser la réponse
    ///   - useCase: Cas d'utilisation du modèle (par défaut: .general)
    ///   - instructions: Instructions personnalisées (optionnel)
    ///   - onUpdate: Callback appelé à chaque mise à jour de la réponse
    ///   - onError: Callback appelé en cas d'erreur
    public static func askStreaming(
        question: String,
        context: String,
        useCase: SystemLanguageModel.UseCase = .general,
        instructions: String? = nil,
        onUpdate: @escaping (String) -> Void,
        onError: ((AIMEError) -> Void)? = nil
    ) async throws {
        guard !question.isEmpty else {
            let error = AIMEError.generationInvalidInput
            onError?(error)
            throw error
        }
        
        guard !context.isEmpty else {
            let error = AIMEError.textProcessingEmptyInput
            onError?(error)
            throw error
        }
        
        AIMELogger.shared.info("Démarrage de la génération en streaming", metadata: [
            "question": question,
            "contextLength": context.count
        ])
        
        do {
            let model = SystemLanguageModel(useCase: useCase)
            
            guard model.isAvailable else {
                let error = AIMEError.generationModelNotAvailable
                onError?(error)
                throw error
            }
            
            let defaultInstructions = """
            Tu es un assistant utile qui répond aux questions de l'utilisateur en te basant UNIQUEMENT sur les informations fournies.
            """
            
            let session = LanguageModelSession(
                model: model,
                instructions: instructions ?? defaultInstructions
            )
            
            let prompt = """
            Question: \(question)
            
            Voici toutes les informations que tu peux utiliser pour répondre à la question:
            \(context)
            """
            
            let stream = session.streamResponse(generating: QuestionAnswerResponse.self) {
                prompt
            }
            
            var fullAnswer = ""
            let inputTokens = TextProcessor.estimateTokenCount(prompt)
            var lastOutputTokens = 0
            
            for try await partialResponse in stream {
                if let isInsufficient = partialResponse.content.insufficientInformation,
                   isInsufficient {
                    fullAnswer = "Je n'ai pas trouvé assez d'informations pour répondre à cette question."
                } else {
                    fullAnswer = partialResponse.content.answer ?? ""
                }
                
                // Enregistrer les tokens à chaque mise à jour (seulement si la réponse a changé)
                let currentOutputTokens = TextProcessor.estimateTokenCount(fullAnswer)
                if currentOutputTokens != lastOutputTokens {
                    TokenTracker.shared.recordUsage(inputTokens: inputTokens, outputTokens: currentOutputTokens)
                    lastOutputTokens = currentOutputTokens
                }
                
                onUpdate(fullAnswer)
            }
            
            AIMELogger.shared.info("Génération en streaming terminée", metadata: [
                "inputTokens": inputTokens,
                "finalOutputTokens": lastOutputTokens
            ])
            
        } catch let error as LanguageModelSession.GenerationError {
            switch error {
            case .guardrailViolation:
                let aimeError = AIMEError.generationGuardrailViolation
                AIMELogger.shared.error("Violation des garde-fous", error: aimeError)
                onError?(aimeError)
                throw aimeError
            default:
                let aimeError = AIMEError.generationUnknownError(error)
                AIMELogger.shared.error("Erreur de génération", error: aimeError)
                onError?(aimeError)
                throw aimeError
            }
        } catch let error as AIMEError {
            onError?(error)
            throw error
        } catch {
            let aimeError = AIMEError.generationUnknownError(error)
            AIMELogger.shared.error("Erreur inconnue", error: aimeError)
            onError?(aimeError)
            throw aimeError
        }
    }
}

