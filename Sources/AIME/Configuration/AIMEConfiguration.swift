/*
 Configuration pour AIME
 */

import Foundation
import FoundationModels
import Speech
#if canImport(AVFoundation)
import AVFoundation
#endif

/// Configuration globale pour AIME
@available(iOS 26.0, macOS 26.0, watchOS 26.0, tvOS 26.0, *)
public struct AIMEConfiguration {
    /// Configuration du modèle de langage
    public var languageModel: LanguageModelConfiguration
    
    /// Configuration du logging
    public var logging: LoggingConfiguration
    
    /// Configuration de la transcription
    public var transcription: TranscriptionConfiguration
    
    /// Configuration de l'enregistrement audio
    public var recording: RecordingConfiguration
    
    /// Initialiseur par défaut
    @available(iOS 26.0, macOS 26.0, watchOS 26.0, tvOS 26.0, *)
    public init(
        languageModel: LanguageModelConfiguration = LanguageModelConfiguration(),
        logging: LoggingConfiguration = LoggingConfiguration(),
        transcription: TranscriptionConfiguration = TranscriptionConfiguration(),
        recording: RecordingConfiguration = RecordingConfiguration()
    ) {
        self.languageModel = languageModel
        self.logging = logging
        self.transcription = transcription
        self.recording = recording
    }
}

/// Configuration du modèle de langage
@available(iOS 26.0, macOS 26.0, watchOS 26.0, tvOS 26.0, *)
public struct LanguageModelConfiguration {
    /// Cas d'utilisation du modèle
    public var useCase: SystemLanguageModel.UseCase
    
    /// Niveau de sécurité (guardrails)
    public var guardrails: SystemLanguageModel.Guardrails
    
    /// Instructions système par défaut
    public var defaultInstructions: String?
    
    /// Outils disponibles pour le modèle
    public var tools: [any Tool]
    
    public init(
        useCase: SystemLanguageModel.UseCase = .general,
        guardrails: SystemLanguageModel.Guardrails = .permissiveContentTransformations,
        defaultInstructions: String? = nil,
        tools: [any Tool] = []
    ) {
        self.useCase = useCase
        self.guardrails = guardrails
        self.defaultInstructions = defaultInstructions
        self.tools = tools
    }
}

/// Configuration du logging
public struct LoggingConfiguration {
    /// Activer le logging
    public var isEnabled: Bool
    
    /// Niveau de logging
    public var level: LogLevel
    
    /// Logger les tokens utilisés
    public var logTokens: Bool
    
    /// Logger les erreurs
    public var logErrors: Bool
    
    /// Logger les performances
    public var logPerformance: Bool
    
    /// Callback personnalisé pour le logging
    public var customLogger: ((LogEntry) -> Void)?
    
    public init(
        isEnabled: Bool = true,
        level: LogLevel = .info,
        logTokens: Bool = true,
        logErrors: Bool = true,
        logPerformance: Bool = false,
        customLogger: ((LogEntry) -> Void)? = nil
    ) {
        self.isEnabled = isEnabled
        self.level = level
        self.logTokens = logTokens
        self.logErrors = logErrors
        self.logPerformance = logPerformance
        self.customLogger = customLogger
    }
}

/// Configuration de la transcription
@available(iOS 26.0, macOS 26.0, watchOS 26.0, tvOS 26.0, *)
public struct TranscriptionConfiguration {
    /// Locale pour la transcription
    public var locale: Locale
    
    /// Options de transcription
    public var transcriptionOptions: Set<SpeechTranscriber.TranscriptionOption>
    
    /// Options de reporting
    public var reportingOptions: Set<SpeechTranscriber.ReportingOption>
    
    /// Options d'attributs
    public var attributeOptions: Set<SpeechTranscriber.ResultAttributeOption>
    
    /// Taille du buffer audio
    public var bufferSize: Int
    
    @available(iOS 26.0, macOS 26.0, watchOS 26.0, tvOS 26.0, *)
    public init(
        locale: Locale = .current,
        transcriptionOptions: Set<SpeechTranscriber.TranscriptionOption> = [],
        reportingOptions: Set<SpeechTranscriber.ReportingOption> = [.volatileResults],
        attributeOptions: Set<SpeechTranscriber.ResultAttributeOption> = [.audioTimeRange],
        bufferSize: Int = 4096
    ) {
        self.locale = locale
        self.transcriptionOptions = transcriptionOptions
        self.reportingOptions = reportingOptions
        self.attributeOptions = attributeOptions
        self.bufferSize = bufferSize
    }
}

/// Configuration de l'enregistrement audio
public struct RecordingConfiguration {
    /// Format audio souhaité
    public var audioFormat: AVAudioFormat?
    
    /// Catégorie de session audio
    public var audioSessionCategory: AVAudioSession.Category
    
    /// Mode de session audio
    public var audioSessionMode: AVAudioSession.Mode
    
    /// Sauvegarder l'audio sur disque
    public var saveToDisk: Bool
    
    /// URL pour sauvegarder l'audio (optionnel)
    public var saveURL: URL?
    
    public init(
        audioFormat: AVAudioFormat? = nil,
        audioSessionCategory: AVAudioSession.Category = .playAndRecord,
        audioSessionMode: AVAudioSession.Mode = .spokenAudio,
        saveToDisk: Bool = true,
        saveURL: URL? = nil
    ) {
        self.audioFormat = audioFormat
        self.audioSessionCategory = audioSessionCategory
        self.audioSessionMode = audioSessionMode
        self.saveToDisk = saveToDisk
        self.saveURL = saveURL
    }
}
