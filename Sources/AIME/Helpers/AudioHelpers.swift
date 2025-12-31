/*
 Helpers pour l'audio
 */

import Foundation
import AVFoundation

#if canImport(AVFoundation)
/// Helpers pour la gestion audio
public struct AudioHelpers {
    
    /// Configurer une session audio
    /// - Parameters:
    ///   - category: Catégorie de session
    ///   - mode: Mode de session
    ///   - options: Options de session
    /// - Throws: Erreur si la configuration échoue
    public static func setupAudioSession(
        category: AVAudioSession.Category = .playAndRecord,
        mode: AVAudioSession.Mode = .spokenAudio,
        options: AVAudioSession.CategoryOptions = []
    ) throws {
        #if os(iOS)
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(category, mode: mode, options: options)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        #endif
    }
    
    /// Obtenir le format audio optimal pour la transcription
    /// - Returns: Format audio recommandé
    public static func getOptimalAudioFormat() -> AVAudioFormat? {
        // Format recommandé pour la transcription vocale
        return AVAudioFormat(
            commonFormat: .pcmFormatFloat32,
            sampleRate: 16000,
            channels: 1,
            interleaved: false
        )
    }
    
    /// Vérifier les autorisations du microphone
    /// - Returns: True si autorisé
    public static func checkMicrophonePermission() async -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .audio)
        if status == .authorized {
            return true
        }
        return await AVCaptureDevice.requestAccess(for: .audio)
    }
}
#endif

