/*
 Module de résumé pour AIME
 */

import Foundation
import FoundationModels
import NaturalLanguage

/// Style de résumé
@available(iOS 26.0, macOS 26.0, watchOS 26.0, tvOS 26.0, *)
public enum SummaryStyle {
    case concise      // Résumé très court
    case standard     // Résumé de longueur moyenne
    case detailed     // Résumé détaillé
    case bulletPoints // Résumé en puces
    
    var description: String {
        switch self {
        case .concise:
            return "Crée un résumé très concis en une ou deux phrases maximum."
        case .standard:
            return "Crée un résumé de longueur moyenne en deux ou trois paragraphes."
        case .detailed:
            return "Crée un résumé détaillé qui couvre tous les points importants."
        case .bulletPoints:
            return "Crée un résumé sous forme de liste à puces avec les points principaux."
        }
    }
}

/// Gestionnaire de résumés
@available(iOS 26.0, macOS 26.0, watchOS 26.0, tvOS 26.0, *)
public struct Summarizer {
    
    /// Générer un résumé d'un texte
    /// - Parameters:
    ///   - text: Le texte à résumer
    ///   - maxLength: Longueur maximale du résumé en caractères (optionnel)
    ///   - style: Style de résumé (par défaut: .standard)
    ///   - useCase: Cas d'utilisation du modèle (par défaut: .general)
    ///   - instructions: Instructions personnalisées (optionnel)
    ///   - timeout: Délai d'attente en secondes (par défaut: 120)
    /// - Returns: Le résumé généré
    public static func generate(
        text: String,
        maxLength: Int? = nil,
        style: SummaryStyle = .standard,
        useCase: SystemLanguageModel.UseCase = .general,
        instructions: String? = nil,
        timeout: TimeInterval = 120
    ) async throws -> String {
        guard !text.isEmpty else {
            throw AIMEError.textProcessingEmptyInput
        }
        
        AIMELogger.shared.info("Génération de résumé", metadata: [
            "textLength": text.count,
            "style": String(describing: style),
            "maxLength": maxLength ?? 0
        ])
        
        let startTime = Date()
        
        do {
            let model = SystemLanguageModel(useCase: useCase, guardrails: .permissiveContentTransformations)
            
            guard model.isAvailable else {
                throw AIMEError.generationModelNotAvailable
            }
            
            let defaultInstructions = """
            Tu es un assistant de réunion utile. Ta tâche est de créer un résumé concis et neutre du texte suivant.
            \(style.description)
            """
            
            let finalInstructions = instructions ?? defaultInstructions
            
            // Si le texte est trop long, utiliser ChunkProcessor
            if text.count > 4096 * 3 {
                let processor = ChunkProcessor(model: model, instructions: finalInstructions, text: text)
                
                let summary = try await processor.process { chunkText in
                    let session = LanguageModelSession(model: model, instructions: finalInstructions)
                    let stream = session.streamResponse(to: chunkText, generating: Summary.self)
                    var chunkSummary = ""
                    for try await partialResponse in stream {
                        chunkSummary = partialResponse.content.summary ?? ""
                    }
                    return chunkSummary + "\n"
                }
                
                let elapsedTime = Date().timeIntervalSince(startTime)
                AIMELogger.shared.info("Résumé généré avec succès (texte long)", metadata: [
                    "elapsedTime": elapsedTime,
                    "summaryLength": summary.count
                ])
                
                return applyMaxLength(summary, maxLength: maxLength)
            } else {
                let session = LanguageModelSession(model: model, instructions: finalInstructions)
                let stream = session.streamResponse(to: text, generating: Summary.self)
                
                var fullSummary = ""
                for try await partialResponse in stream {
                    fullSummary = partialResponse.content.summary ?? ""
                }
                
                let elapsedTime = Date().timeIntervalSince(startTime)
                AIMELogger.shared.info("Résumé généré avec succès", metadata: [
                    "elapsedTime": elapsedTime,
                    "summaryLength": fullSummary.count
                ])
                
                return applyMaxLength(fullSummary, maxLength: maxLength)
            }
            
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
    
    /// Générer un résumé avec streaming
    /// - Parameters:
    ///   - text: Le texte à résumer
    ///   - maxLength: Longueur maximale (optionnel)
    ///   - style: Style de résumé
    ///   - useCase: Cas d'utilisation
    ///   - instructions: Instructions personnalisées
    ///   - onUpdate: Callback appelé à chaque mise à jour
    ///   - onError: Callback appelé en cas d'erreur
    public static func generateStreaming(
        text: String,
        maxLength: Int? = nil,
        style: SummaryStyle = .standard,
        useCase: SystemLanguageModel.UseCase = .general,
        instructions: String? = nil,
        onUpdate: @escaping (String) -> Void,
        onError: ((AIMEError) -> Void)? = nil
    ) async throws {
        guard !text.isEmpty else {
            let error = AIMEError.textProcessingEmptyInput
            onError?(error)
            throw error
        }
        
        AIMELogger.shared.info("Démarrage de la génération de résumé en streaming")
        
        do {
            let model = SystemLanguageModel(useCase: useCase, guardrails: .permissiveContentTransformations)
            
            guard model.isAvailable else {
                let error = AIMEError.generationModelNotAvailable
                onError?(error)
                throw error
            }
            
            let defaultInstructions = """
            Tu es un assistant de réunion utile. Ta tâche est de créer un résumé concis et neutre du texte suivant.
            \(style.description)
            """
            
            let session = LanguageModelSession(
                model: model,
                instructions: instructions ?? defaultInstructions
            )
            
            let stream = session.streamResponse(to: text, generating: Summary.self)
            
            for try await partialResponse in stream {
                let summary = partialResponse.content.summary ?? ""
                let truncated = applyMaxLength(summary, maxLength: maxLength)
                onUpdate(truncated)
            }
            
            AIMELogger.shared.info("Génération de résumé en streaming terminée")
            
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
    
    private static func applyMaxLength(_ text: String, maxLength: Int?) -> String {
        guard let maxLength = maxLength, text.count > maxLength else {
            return text
        }
        let index = text.index(text.startIndex, offsetBy: maxLength)
        return String(text[..<index]) + "..."
    }
}

@Generable
private struct Summary {
    var summary: String
}

// Helper pour le traitement par chunks
private struct ChunkProcessor {
    let model: SystemLanguageModel
    let instructions: String
    let text: String
    let ranges: [Range<String.Index>]
    
    init(model: SystemLanguageModel, instructions: String, text: String) {
        self.model = model
        self.instructions = instructions
        self.text = text
        
        let tokenizer = NLTokenizer(unit: .paragraph)
        tokenizer.string = text
        self.ranges = tokenizer.tokens(for: text.startIndex ..< text.endIndex)
    }
    
    func process(operation: (String) async throws -> String) async throws -> String {
        try await ChunkProcessor.process(text, ranges: ranges, operation: operation)
    }
    
    static func process(
        _ string: String,
        ranges: [Range<String.Index>],
        operation: (String) async throws -> String
    ) async throws -> String {
        guard !ranges.isEmpty && !string.isEmpty else {
            throw AIMEError.textProcessingEmptyInput
        }
        
        let fullRange = ranges.first!.lowerBound ..< ranges.last!.upperBound
        let fullText = String(string[fullRange])
        
        do {
            guard fullText.count < 4096 * 3 else {
                throw AIMEError.textProcessingTooLarge
            }
            
            return try await operation(fullText)
        } catch {
            guard ranges.count > 1 else {
                throw AIMEError.textProcessingChunkingFailed
            }
            
            let midpoint = ranges.count / 2
            let firstHalf = Array(ranges[..<midpoint])
            let secondHalf = Array(ranges[midpoint...])
            
            let firstResult = try await process(string, ranges: firstHalf, operation: operation)
            let secondResult = try await process(string, ranges: secondHalf, operation: operation)
            
            return firstResult + "\n" + secondResult
        }
    }
}

