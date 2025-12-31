/*
 Module d'extraction d'action items pour AIME
 */

import Foundation
import FoundationModels

/// Gestionnaire d'extraction d'action items
@available(iOS 26.0, macOS 26.0, watchOS 26.0, tvOS 26.0, *)
public struct ActionItemsExtractor {
    
    /// Extraire les action items d'un texte
    /// - Parameters:
    ///   - text: Le texte à analyser
    ///   - maxItems: Nombre maximum d'action items à extraire (par défaut: 10)
    ///   - useCase: Cas d'utilisation du modèle (par défaut: .general)
    ///   - instructions: Instructions personnalisées (optionnel)
    ///   - includePriority: Inclure la priorité des items (par défaut: false)
    ///   - includeOwner: Inclure le propriétaire de chaque item (par défaut: false)
    ///   - includeDueDate: Inclure la date d'échéance (par défaut: false)
    /// - Returns: Liste des action items extraits
    public static func extract(
        text: String,
        maxItems: Int = 10,
        useCase: SystemLanguageModel.UseCase = .general,
        instructions: String? = nil,
        includePriority: Bool = false,
        includeOwner: Bool = false,
        includeDueDate: Bool = false
    ) async throws -> [ActionItem] {
        guard !text.isEmpty else {
            throw AIMEError.textProcessingEmptyInput
        }
        
        AIMELogger.shared.info("Extraction d'action items", metadata: [
            "textLength": text.count,
            "maxItems": maxItems
        ])
        
        let startTime = Date()
        
        do {
            let model = SystemLanguageModel(useCase: useCase, guardrails: .permissiveContentTransformations)
            
            guard model.isAvailable else {
                throw AIMEError.generationModelNotAvailable
            }
            
            let defaultInstructions = """
            Tu es un assistant utile. Ta tâche est d'extraire les action items prioritaires des transcriptions de réunions d'équipe.
            Le texte fourni contient des transcriptions de réunions d'équipe.
            Tu DOIS retourner une liste d'action items prioritaires basée UNIQUEMENT sur le texte fourni.
            """
            
            let session = LanguageModelSession(
                model: model,
                instructions: instructions ?? defaultInstructions
            )
            
            @Generable
            struct ActionItemsResponse {
                @Guide(description: "Une liste d'action items prioritaires de la réunion", .maximumCount(maxItems))
                var actionItems: [String]
            }
            
            let stream = session.streamResponse(to: text, generating: ActionItemsResponse.self)
            
            var actionItems: [String] = []
            for try await partialResponse in stream {
                actionItems = partialResponse.content.actionItems ?? []
            }
            
            let items = actionItems.enumerated().map { index, item in
                ActionItem(
                    id: UUID(),
                    title: item,
                    priority: nil,
                    owner: nil,
                    dueDate: nil,
                    index: index
                )
            }
            
            let elapsedTime = Date().timeIntervalSince(startTime)
            AIMELogger.shared.info("Action items extraits avec succès", metadata: [
                "elapsedTime": elapsedTime,
                "itemCount": items.count
            ])
            
            return items
            
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
    
    /// Extraire les action items avec streaming
    /// - Parameters:
    ///   - text: Le texte à analyser
    ///   - maxItems: Nombre maximum d'items
    ///   - useCase: Cas d'utilisation
    ///   - instructions: Instructions personnalisées
    ///   - onUpdate: Callback appelé à chaque mise à jour
    ///   - onError: Callback appelé en cas d'erreur
    public static func extractStreaming(
        text: String,
        maxItems: Int = 10,
        useCase: SystemLanguageModel.UseCase = .general,
        instructions: String? = nil,
        onUpdate: @escaping ([ActionItem]) -> Void,
        onError: ((AIMEError) -> Void)? = nil
    ) async throws {
        guard !text.isEmpty else {
            let error = AIMEError.textProcessingEmptyInput
            onError?(error)
            throw error
        }
        
        AIMELogger.shared.info("Démarrage de l'extraction d'action items en streaming")
        
        do {
            let model = SystemLanguageModel(useCase: useCase, guardrails: .permissiveContentTransformations)
            
            guard model.isAvailable else {
                let error = AIMEError.generationModelNotAvailable
                onError?(error)
                throw error
            }
            
            let defaultInstructions = """
            Tu es un assistant utile. Ta tâche est d'extraire les action items prioritaires des transcriptions de réunions d'équipe.
            """
            
            let session = LanguageModelSession(
                model: model,
                instructions: instructions ?? defaultInstructions
            )
            
            @Generable
            struct ActionItemsResponse {
                @Guide(description: "Une liste d'action items prioritaires de la réunion", .maximumCount(maxItems))
                var actionItems: [String]
            }
            
            let stream = session.streamResponse(to: text, generating: ActionItemsResponse.self)
            
            for try await partialResponse in stream {
                let actionItems = partialResponse.content.actionItems ?? []
                let items = actionItems.enumerated().map { index, item in
                    ActionItem(
                        id: UUID(),
                        title: item,
                        priority: nil,
                        owner: nil,
                        dueDate: nil,
                        index: index
                    )
                }
                onUpdate(items)
            }
            
            AIMELogger.shared.info("Extraction d'action items en streaming terminée")
            
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

/// Représente un action item
public struct ActionItem: Identifiable {
    public let id: UUID
    public let title: String
    public let priority: Priority?
    public let owner: String?
    public let dueDate: Date?
    public let index: Int
    
    public init(
        id: UUID = UUID(),
        title: String,
        priority: Priority? = nil,
        owner: String? = nil,
        dueDate: Date? = nil,
        index: Int = 0
    ) {
        self.id = id
        self.title = title
        self.priority = priority
        self.owner = owner
        self.dueDate = dueDate
        self.index = index
    }
}

/// Priorité d'un action item
public enum Priority: String, CaseIterable {
    case critical = "Critique"
    case high = "Élevée"
    case medium = "Moyenne"
    case low = "Basse"
    case unspecified = "Non spécifiée"
}

