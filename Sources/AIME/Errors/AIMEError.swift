/*
 Gestion d'erreurs pour AIME
 */

import Foundation
import Speech
import AVFoundation

/// Erreurs possibles dans AIME
public enum AIMEError: LocalizedError {
    // Erreurs de transcription
    case transcriptionNotAuthorized
    case transcriptionSetupFailed
    case transcriptionLocaleNotSupported(Locale)
    case transcriptionModelDownloadFailed(Error?)
    case transcriptionNoInternetConnection
    case transcriptionInvalidAudioFormat
    case transcriptionAudioSessionFailed(Error)
    
    // Erreurs d'enregistrement
    case recordingNotAuthorized
    case recordingSetupFailed(Error)
    case recordingStartFailed(Error)
    case recordingStopFailed(Error)
    case recordingFileWriteFailed(Error)
    case recordingInvalidConfiguration
    
    // Erreurs de génération de texte
    case generationModelNotAvailable
    case generationGuardrailViolation
    case generationInvalidInput
    case generationTimeout
    case generationCancelled
    case generationUnknownError(Error)
    
    // Erreurs de traitement de texte
    case textProcessingEmptyInput
    case textProcessingTooLarge
    case textProcessingChunkingFailed
    
    // Erreurs de configuration
    case configurationInvalid(String)
    
    public var errorDescription: String? {
        switch self {
        case .transcriptionNotAuthorized:
            return "L'autorisation pour la transcription vocale n'a pas été accordée."
        case .transcriptionSetupFailed:
            return "Impossible de configurer la transcription vocale."
        case .transcriptionLocaleNotSupported(let locale):
            return "La locale \(locale.identifier) n'est pas supportée pour la transcription."
        case .transcriptionModelDownloadFailed(let error):
            if let error = error {
                return "Échec du téléchargement du modèle de transcription: \(error.localizedDescription)"
            }
            return "Échec du téléchargement du modèle de transcription."
        case .transcriptionNoInternetConnection:
            return "Aucune connexion Internet pour télécharger le modèle de transcription."
        case .transcriptionInvalidAudioFormat:
            return "Format audio invalide pour la transcription."
        case .transcriptionAudioSessionFailed(let error):
            return "Échec de la session audio: \(error.localizedDescription)"
            
        case .recordingNotAuthorized:
            return "L'autorisation pour l'enregistrement audio n'a pas été accordée."
        case .recordingSetupFailed(let error):
            return "Échec de la configuration de l'enregistrement: \(error.localizedDescription)"
        case .recordingStartFailed(let error):
            return "Échec du démarrage de l'enregistrement: \(error.localizedDescription)"
        case .recordingStopFailed(let error):
            return "Échec de l'arrêt de l'enregistrement: \(error.localizedDescription)"
        case .recordingFileWriteFailed(let error):
            return "Échec de l'écriture du fichier audio: \(error.localizedDescription)"
        case .recordingInvalidConfiguration:
            return "Configuration d'enregistrement invalide."
            
        case .generationModelNotAvailable:
            return "Le modèle de langage n'est pas disponible."
        case .generationGuardrailViolation:
            return "La génération a été bloquée par les garde-fous de sécurité."
        case .generationInvalidInput:
            return "L'entrée fournie est invalide pour la génération."
        case .generationTimeout:
            return "La génération a dépassé le délai d'attente."
        case .generationCancelled:
            return "La génération a été annulée."
        case .generationUnknownError(let error):
            return "Erreur inconnue lors de la génération: \(error.localizedDescription)"
            
        case .textProcessingEmptyInput:
            return "Le texte fourni est vide."
        case .textProcessingTooLarge:
            return "Le texte fourni est trop volumineux pour être traité."
        case .textProcessingChunkingFailed:
            return "Échec de la division du texte en morceaux."
            
        case .configurationInvalid(let message):
            return "Configuration invalide: \(message)"
        }
    }
    
    public var failureReason: String? {
        switch self {
        case .transcriptionNotAuthorized:
            return "L'utilisateur doit accorder l'autorisation d'accès au microphone dans les réglages."
        case .generationModelNotAvailable:
            return "Apple Intelligence n'est pas disponible sur cet appareil ou dans cette région."
        case .generationGuardrailViolation:
            return "Le contenu généré viole les politiques de sécurité d'Apple."
        default:
            return nil
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .transcriptionNotAuthorized, .recordingNotAuthorized:
            return "Vérifiez les autorisations dans Réglages > Confidentialité et sécurité."
        case .transcriptionNoInternetConnection:
            return "Vérifiez votre connexion Internet et réessayez."
        case .generationModelNotAvailable:
            return "Vérifiez que votre appareil supporte Apple Intelligence et que vous êtes dans une région supportée."
        default:
            return nil
        }
    }
}

