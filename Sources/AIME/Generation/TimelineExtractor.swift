/*
 Module d'extraction de timeline pour AIME
 */

import Foundation
import FoundationModels

// Types Generable pour TimelineExtractor
@available(iOS 26.0, macOS 26.0, watchOS 26.0, tvOS 26.0, *)
@Generable
private enum TimelinePriorityResponse {
    case critical
    case high
    case medium
    case low
    case unspecified
}

@available(iOS 26.0, macOS 26.0, watchOS 26.0, tvOS 26.0, *)
@Generable
private struct TimelineItemResponse {
    @Guide(description: "Titre de l'item/jalon/tâche sur la timeline du projet")
    var title: String
    
    @Guide(description: "Date d'échéance ou période pour cet item")
    var date: String
    
    @Guide(description: "Nom de l'individu responsable de cet item, UNIQUEMENT si spécifié")
    var owner: String?
    
    @Guide(description: "Statut actuel de l'item de timeline, UNIQUEMENT si mentionné dans les transcriptions, ex: 'terminé', 'en cours', 'bloqué', 'planifié'")
    var status: String?
    
    @Guide(description: "Priorité de l'item de timeline, UNIQUEMENT si mentionnée")
    var priority: TimelinePriorityResponse?
}

@available(iOS 26.0, macOS 26.0, watchOS 26.0, tvOS 26.0, *)
@Generable
private struct TimelineResponse {
    @Guide(description: "Tableau d'items de timeline (jalons et tâches) extraits des transcriptions de réunions")
    var timeline: [TimelineItemResponse]?
    
    @Guide(description: "Toutes notes importantes ou ambiguïtés rencontrées lors de l'extraction")
    var extractionNotes: String?
}

/// Gestionnaire d'extraction de timeline
@available(iOS 26.0, macOS 26.0, watchOS 26.0, tvOS 26.0, *)
public struct TimelineExtractor {
    
    /// Extraire une timeline d'un texte
    /// - Parameters:
    ///   - text: Le texte à analyser
    ///   - useCase: Cas d'utilisation du modèle (par défaut: .general)
    ///   - instructions: Instructions personnalisées (optionnel)
    ///   - includeStatus: Inclure le statut des items (par défaut: true)
    ///   - includePriority: Inclure la priorité (par défaut: true)
    ///   - includeOwner: Inclure le propriétaire (par défaut: true)
    /// - Returns: La timeline extraite
    public static func extract(
        text: String,
        useCase: SystemLanguageModel.UseCase = .general,
        instructions: String? = nil,
        includeStatus: Bool = true,
        includePriority: Bool = true,
        includeOwner: Bool = true
    ) async throws -> Timeline {
        guard !text.isEmpty else {
            throw AIMEError.textProcessingEmptyInput
        }
        
        AIMELogger.shared.info("Extraction de timeline", metadata: [
            "textLength": text.count
        ])
        
        let startTime = Date()
        
        do {
            let model = SystemLanguageModel(useCase: useCase, guardrails: .permissiveContentTransformations)
            
            guard model.isAvailable else {
                throw AIMEError.generationModelNotAvailable
            }
            
            let defaultInstructions = """
            Tu es un assistant d'extraction de timeline de projet. Ta tâche est d'analyser les transcriptions de réunions et de générer une timeline structurée contenant des jalons et des tâches.
            
            INSTRUCTIONS:
            1. Extrais tous les jalons, livrables et tâches actionnables mentionnés dans les transcriptions de réunions fournies
            2. Pour chaque item, identifie:
               - Un titre/description clair du jalon/tâche
               - Propriétaire/assigné (personne individuelle responsable)
               - Date d'échéance (dates explicites, dates relatives comme "la semaine prochaine", ou périodes inférées)
               - Statut si mentionné (ex: "en cours", "terminé", "planifié", "bloqué")
               - Priorité si mentionnée (ex: "élevée", "moyenne", "basse", "critique")
            3. Consolide les informations de plusieurs transcriptions en une timeline cohérente
            4. N'inclus que les informations explicitement énoncées ou raisonnablement inférées des transcriptions
            5. Si une date est mentionnée relativement (ex: "vendredi prochain", "dans deux semaines"), préserve-la telle qu'énoncée mais marque-la comme relative
            6. Si des informations critiques manquent ou sont peu claires, note-les dans le champ approprié
            
            BASE TA RÉPONSE UNIQUEMENT SUR LES TRANSCRIPTIONS FOURNIES. N'ajoute pas d'hypothèses ou d'informations non présentes dans le texte.
            Si le texte ne contient pas de tâches ou de livrables, dis "Il n'y a pas de tâches ni de timeline".
            """
            
            let session = LanguageModelSession(
                model: model,
                instructions: instructions ?? defaultInstructions
            )
            
            let stream = session.streamResponse(to: text, generating: TimelineResponse.self)
            
            var timelineItems: [TimelineItemResponse] = []
            var notes: String?
            
            for try await partialResponse in stream {
                timelineItems = partialResponse.content.timeline ?? []
                notes = partialResponse.content.extractionNotes
            }
            
            let items = timelineItems.map { item in
                TimelineItem(
                    id: UUID(),
                    title: item.title,
                    date: item.date,
                    owner: item.owner,
                    status: item.status,
                    priority: mapPriority(item.priority)
                )
            }
            
            let timeline = Timeline(
                items: items,
                extractionNotes: notes
            )
            
            let elapsedTime = Date().timeIntervalSince(startTime)
            AIMELogger.shared.info("Timeline extraite avec succès", metadata: [
                "elapsedTime": elapsedTime,
                "itemCount": items.count
            ])
            
            return timeline
            
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
    
    /// Extraire une timeline avec streaming
    /// - Parameters:
    ///   - text: Le texte à analyser
    ///   - useCase: Cas d'utilisation
    ///   - instructions: Instructions personnalisées
    ///   - onUpdate: Callback appelé à chaque mise à jour
    ///   - onError: Callback appelé en cas d'erreur
    public static func extractStreaming(
        text: String,
        useCase: SystemLanguageModel.UseCase = .general,
        instructions: String? = nil,
        onUpdate: @escaping (Timeline) -> Void,
        onError: ((AIMEError) -> Void)? = nil
    ) async throws {
        guard !text.isEmpty else {
            let error = AIMEError.textProcessingEmptyInput
            onError?(error)
            throw error
        }
        
        AIMELogger.shared.info("Démarrage de l'extraction de timeline en streaming")
        
        do {
            let model = SystemLanguageModel(useCase: useCase, guardrails: .permissiveContentTransformations)
            
            guard model.isAvailable else {
                let error = AIMEError.generationModelNotAvailable
                onError?(error)
                throw error
            }
            
            let defaultInstructions = """
            Tu es un assistant d'extraction de timeline de projet. Ta tâche est d'analyser les transcriptions de réunions et de générer une timeline structurée.
            """
            
            let session = LanguageModelSession(
                model: model,
                instructions: instructions ?? defaultInstructions
            )
            
            let stream = session.streamResponse(to: text, generating: TimelineResponse.self)
            
            for try await partialResponse in stream {
                let timelineItems = partialResponse.content.timeline ?? []
                let items = timelineItems.map { item in
                    TimelineItem(
                        id: UUID(),
                        title: item.title,
                        date: item.date,
                        owner: item.owner,
                        status: item.status,
                        priority: mapPriority(item.priority)
                    )
                }
                
                let timeline = Timeline(
                    items: items,
                    extractionNotes: partialResponse.content.extractionNotes
                )
                
                onUpdate(timeline)
            }
            
            AIMELogger.shared.info("Extraction de timeline en streaming terminée")
            
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
    
    private static func mapPriority(_ priority: TimelinePriorityResponse?) -> Priority? {
        guard let priority = priority else { return nil }
        switch priority {
        case .critical:
            return .critical
        case .high:
            return .high
        case .medium:
            return .medium
        case .low:
            return .low
        case .unspecified:
            return .unspecified
        }
    }
}

/// Représente une timeline
public struct Timeline {
    public let items: [TimelineItem]
    public let extractionNotes: String?
    
    public init(items: [TimelineItem], extractionNotes: String? = nil) {
        self.items = items
        self.extractionNotes = extractionNotes
    }
}

/// Représente un item de timeline
public struct TimelineItem: Identifiable {
    public let id: UUID
    public let title: String
    public let date: String
    public let owner: String?
    public let status: String?
    public let priority: Priority?
    
    public init(
        id: UUID = UUID(),
        title: String,
        date: String,
        owner: String? = nil,
        status: String? = nil,
        priority: Priority? = nil
    ) {
        self.id = id
        self.title = title
        self.date = date
        self.owner = owner
        self.status = status
        self.priority = priority
    }
}

