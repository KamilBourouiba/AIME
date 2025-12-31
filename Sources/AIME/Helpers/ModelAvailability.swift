/*
 Vérification de la disponibilité des modèles
 */

import Foundation
import FoundationModels
import Speech

/// Vérificateur de disponibilité des modèles
public struct ModelAvailability {
    
    /// Vérifier si Apple Intelligence est disponible
    /// - Parameter useCase: Cas d'utilisation à vérifier (par défaut: .general)
    /// - Returns: True si disponible
    public static func isAvailable(useCase: SystemLanguageModel.UseCase = .general) -> Bool {
        let model = SystemLanguageModel(useCase: useCase)
        return model.isAvailable
    }
    
    /// Obtenir la raison de l'indisponibilité
    /// - Parameter useCase: Cas d'utilisation
    /// - Returns: Raison de l'indisponibilité ou nil si disponible
    public static func unavailabilityReason(useCase: SystemLanguageModel.UseCase = .general) -> SystemLanguageModel.UnavailabilityReason? {
        let model = SystemLanguageModel(useCase: useCase)
        switch model.availability {
        case .available:
            return nil
        case .unavailable(let reason):
            return reason
        }
    }
    
    /// Vérifier si la transcription vocale est disponible
    /// - Parameter locale: Locale à vérifier (par défaut: .current)
    /// - Returns: True si disponible
    public static func isTranscriptionAvailable(locale: Locale = .current) async -> Bool {
        let supported = await SpeechTranscriber.supportedLocales
        return supported.map { $0.language }.contains(locale.language)
    }
    
    /// Vérifier si un modèle de transcription est installé
    /// - Parameter locale: Locale à vérifier
    /// - Returns: True si installé
    public static func isTranscriptionModelInstalled(locale: Locale = .current) async -> Bool {
        let installed = await Set(SpeechTranscriber.installedLocales)
        return installed.map { $0.language }.contains(locale.language)
    }
}
