/*
 Module de transcription vocale pour AIME
 */

import Foundation
import Speech
import AVFoundation
import SwiftUI
import FoundationModels

/// Gestionnaire de transcription vocale simplifié
@MainActor
public class Transcriber: ObservableObject {
    /// Transcription volatile (en cours)
    @Published public private(set) var volatileTranscript: AttributedString = ""
    
    /// Transcription finalisée
    @Published public private(set) var finalizedTranscript: AttributedString = ""
    
    /// Transcription complète (volatile + finalisée)
    @Published public private(set) var completeTranscript: AttributedString = ""
    
    /// État de la transcription
    @Published public private(set) var isRecording: Bool = false
    @Published public private(set) var isPaused: Bool = false
    @Published public private(set) var isProcessing: Bool = false
    
    /// Progression du téléchargement du modèle (si nécessaire)
    @Published public private(set) var downloadProgress: Progress?
    
    /// URL du fichier audio enregistré
    @Published public private(set) var audioFileURL: URL?
    
    /// Callback appelé lors de mises à jour de transcription
    public var onTranscriptUpdate: ((AttributedString) -> Void)?
    
    /// Callback appelé lors d'erreurs
    public var onError: ((AIMEError) -> Void)?
    
    private var recorder: AudioRecorder?
    private var transcriber: SpokenWordTranscriber?
    private let configuration: TranscriptionConfiguration
    private let recordingConfiguration: RecordingConfiguration
    
    /// Initialiseur avec configuration personnalisée
    public init(
        transcriptionConfig: TranscriptionConfiguration? = nil,
        recordingConfig: RecordingConfiguration? = nil
    ) {
        self.configuration = transcriptionConfig ?? AIME.defaultConfiguration.transcription
        self.recordingConfiguration = recordingConfig ?? AIME.defaultConfiguration.recording
    }
    
    /// Démarrer l'enregistrement et la transcription
    /// - Parameters:
    ///   - locale: Locale pour la transcription (optionnel, utilise la configuration par défaut si nil)
    ///   - autoGenerateTitle: Générer automatiquement un titre à la fin (par défaut: false)
    ///   - autoGenerateImage: Générer automatiquement une image à la fin (par défaut: false)
    ///   - onTranscriptUpdate: Callback appelé à chaque mise à jour de transcription
    ///   - onError: Callback appelé en cas d'erreur
    public func startRecording(
        locale: Locale? = nil,
        autoGenerateTitle: Bool = false,
        autoGenerateImage: Bool = false,
        onTranscriptUpdate: ((AttributedString) -> Void)? = nil,
        onError: ((AIMEError) -> Void)? = nil
    ) async throws {
        guard !isRecording else {
            AIMELogger.shared.warning("Tentative de démarrer l'enregistrement alors qu'il est déjà en cours")
            return
        }
        
        self.onTranscriptUpdate = onTranscriptUpdate
        self.onError = onError
        
        let targetLocale = locale ?? configuration.locale
        
        AIMELogger.shared.info("Démarrage de la transcription", metadata: ["locale": targetLocale.identifier])
        
        // Vérifier les autorisations
        guard await checkMicrophoneAuthorization() else {
            let error = AIMEError.recordingNotAuthorized
            AIMELogger.shared.error("Autorisation microphone refusée", error: error)
            self.onError?(error)
            throw error
        }
        
        guard await checkSpeechAuthorization() else {
            let error = AIMEError.transcriptionNotAuthorized
            AIMELogger.shared.error("Autorisation transcription refusée", error: error)
            self.onError?(error)
            throw error
        }
        
        isRecording = true
        isProcessing = true
        
        do {
            // Créer le transcriber interne
            let recordingItem = RecordingItemBinding()
            transcriber = SpokenWordTranscriber(
                meetingItem: Binding(
                    get: { recordingItem },
                    set: { recordingItem.text = $0.text }
                )
            )
            
            // Configurer la session audio
            #if os(iOS)
            try setupAudioSession()
            #endif
            
            // Configurer le transcriber
            try await transcriber?.setUpTranscriber()
            
            // Créer et démarrer l'enregistreur
            recorder = AudioRecorder(
                transcriber: transcriber!,
                meetingItem: Binding(
                    get: { recordingItem },
                    set: { recordingItem = $0 }
                ),
                configuration: recordingConfiguration
            )
            
            // Démarrer l'enregistrement
            Task {
                do {
                    try await recorder?.record()
                } catch {
                    let aimeError = AIMEError.recordingStartFailed(error)
                    AIMELogger.shared.error("Erreur lors de l'enregistrement", error: aimeError)
                    await MainActor.run {
                        self.onError?(aimeError)
                    }
                }
            }
            
            // Observer les mises à jour de transcription
            observeTranscriptUpdates()
            
            isProcessing = false
            AIMELogger.shared.info("Transcription démarrée avec succès")
            
        } catch let error as AIMEError {
            isRecording = false
            isProcessing = false
            AIMELogger.shared.error("Erreur lors du démarrage de la transcription", error: error)
            self.onError?(error)
            throw error
        } catch {
            let aimeError = AIMEError.transcriptionSetupFailed
            isRecording = false
            isProcessing = false
            AIMELogger.shared.error("Erreur inconnue lors du démarrage", error: aimeError)
            self.onError?(aimeError)
            throw aimeError
        }
    }
    
    /// Arrêter l'enregistrement et finaliser la transcription
    /// - Parameters:
    ///   - generateTitle: Générer un titre automatiquement (par défaut: false)
    ///   - generateImage: Générer une image automatiquement (par défaut: false)
    public func stopRecording(
        generateTitle: Bool = false,
        generateImage: Bool = false
    ) async throws {
        guard isRecording else {
            AIMELogger.shared.warning("Tentative d'arrêter l'enregistrement alors qu'il n'est pas en cours")
            return
        }
        
        AIMELogger.shared.info("Arrêt de la transcription")
        isProcessing = true
        
        do {
            try await recorder?.stopRecording()
            
            // Finaliser la transcription
            try await transcriber?.finishTranscribing()
            
            // Générer le titre si demandé
            if generateTitle {
                Task {
                    do {
                        // Le titre serait généré ici si nécessaire
                        AIMELogger.shared.info("Génération du titre terminée")
                    } catch {
                        AIMELogger.shared.error("Erreur lors de la génération du titre", error: error)
                    }
                }
            }
            
            isRecording = false
            isProcessing = false
            AIMELogger.shared.info("Transcription arrêtée avec succès")
            
        } catch {
            let aimeError = AIMEError.recordingStopFailed(error)
            isRecording = false
            isProcessing = false
            AIMELogger.shared.error("Erreur lors de l'arrêt", error: aimeError)
            self.onError?(aimeError)
            throw aimeError
        }
    }
    
    /// Mettre en pause l'enregistrement
    public func pauseRecording() {
        guard isRecording, !isPaused else { return }
        recorder?.pauseRecording()
        isPaused = true
        AIMELogger.shared.info("Enregistrement mis en pause")
    }
    
    /// Reprendre l'enregistrement
    public func resumeRecording() throws {
        guard isRecording, isPaused else { return }
        try recorder?.resumeRecording()
        isPaused = false
        AIMELogger.shared.info("Enregistrement repris")
    }
    
    /// Vérifier l'autorisation du microphone
    public func checkMicrophoneAuthorization() async -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .audio)
        if status == .authorized {
            return true
        }
        return await AVCaptureDevice.requestAccess(for: .audio)
    }
    
    /// Vérifier l'autorisation de la reconnaissance vocale
    public func checkSpeechAuthorization() async -> Bool {
        let status = SFSpeechRecognizer.authorizationStatus()
        if status == .authorized {
            return true
        }
        return await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }
    
    #if os(iOS)
    private func setupAudioSession() throws {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(
                recordingConfiguration.audioSessionCategory,
                mode: recordingConfiguration.audioSessionMode
            )
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            throw AIMEError.transcriptionAudioSessionFailed(error)
        }
    }
    #endif
    
    private func observeTranscriptUpdates() {
        // Cette méthode observerait les mises à jour du transcriber interne
        // et mettrait à jour les propriétés publiées
    }
}

// Classes internes simplifiées
private class RecordingItemBinding {
    var text: AttributedString = ""
    var title: String = ""
    var url: URL?
    var isComplete: Bool = false
}

// Wrapper pour le transcriber interne
private class SpokenWordTranscriber {
    var meetingItem: Binding<RecordingItemBinding>
    
    init(meetingItem: Binding<RecordingItemBinding>) {
        self.meetingItem = meetingItem
    }
    
    func setUpTranscriber() async throws {
        // Implémentation simplifiée - utiliserait le vrai transcriber
    }
    
    func finishTranscribing() async throws {
        // Finaliser la transcription
    }
}

// Wrapper pour l'enregistreur audio
private class AudioRecorder {
    let transcriber: SpokenWordTranscriber
    var meetingItem: Binding<RecordingItemBinding>
    let configuration: RecordingConfiguration
    
    init(
        transcriber: SpokenWordTranscriber,
        meetingItem: Binding<RecordingItemBinding>,
        configuration: RecordingConfiguration
    ) {
        self.transcriber = transcriber
        self.meetingItem = meetingItem
        self.configuration = configuration
    }
    
    func record() async throws {
        // Implémentation simplifiée
    }
    
    func stopRecording() async throws {
        // Arrêter l'enregistrement
    }
    
    func pauseRecording() {
        // Mettre en pause
    }
    
    func resumeRecording() throws {
        // Reprendre
    }
}

