/*
 Vérification de la disponibilité des modèles
 */

import Foundation
import FoundationModels
import Speech

/// Vérificateur de disponibilité des modèles
@available(iOS 26.0, macOS 26.0, watchOS 26.0, tvOS 26.0, *)
public struct ModelAvailability {
    
    /// Vérifier si Apple Intelligence est disponible
    /// - Parameter useCase: Cas d'utilisation à vérifier (par défaut: .general)
    /// - Returns: True si disponible
    @available(iOS 26.0, macOS 26.0, watchOS 26.0, tvOS 26.0, *)
    public static func isAvailable(useCase: SystemLanguageModel.UseCase = .general) -> Bool {
        let model = SystemLanguageModel(useCase: useCase)
        return model.isAvailable
    }
    
    /// Obtenir la raison de l'indisponibilité
    /// - Parameter useCase: Cas d'utilisation
    /// - Returns: Raison de l'indisponibilité ou nil si disponible
    @available(iOS 26.0, macOS 26.0, watchOS 26.0, tvOS 26.0, *)
    public static func unavailabilityReason(useCase: SystemLanguageModel.UseCase = .general) -> (any Sendable)? {
        let model = SystemLanguageModel(useCase: useCase)
        switch model.availability {
        case .available:
            return nil
        case .unavailable(let reason):
            return reason as? any Sendable
        }
    }
    
    /// Vérifier si la transcription vocale est disponible
    /// - Parameter locale: Locale à vérifier (par défaut: .current)
    /// - Returns: True si disponible
    @available(iOS 26.0, macOS 26.0, watchOS 26.0, tvOS 26.0, *)
    public static func isTranscriptionAvailable(locale: Locale = .current) async -> Bool {
        let supported = await SpeechTranscriber.supportedLocales
        return supported.map { $0.language }.contains(locale.language)
    }
    
    /// Vérifier si un modèle de transcription est installé
    /// - Parameter locale: Locale à vérifier
    /// - Returns: True si installé
    @available(iOS 26.0, macOS 26.0, watchOS 26.0, tvOS 26.0, *)
    public static func isTranscriptionModelInstalled(locale: Locale = .current) async -> Bool {
        let installed = await Set(SpeechTranscriber.installedLocales)
        return installed.map { $0.language }.contains(locale.language)
    }
}
