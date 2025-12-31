/*
 AIME - Apple Intelligence Made Easy
 Par Kamil Bourouiba
 
 API simplifiée style OpenAI pour FoundationModels
 Tout est dans votre code - Aucun prompt hardcodé
 */

import Foundation

/// Point d'entrée principal du package AIME
@available(iOS 26.0, macOS 26.0, watchOS 26.0, tvOS 26.0, *)
public enum AIME {
    /// Version actuelle du package
    public static let version = "3.0.0"
    
    /// Créer un client AIME (style OpenAI)
    /// - Parameters:
    ///   - useCase: Cas d'utilisation du modèle
    ///   - systemPrompt: Votre prompt système personnalisé
    /// - Returns: Un client AIME configuré
    public static func client(
        useCase: SystemLanguageModel.UseCase = .general,
        systemPrompt: String? = nil
    ) throws -> AIMEClient {
        return try AIMEClient(useCase: useCase, systemPrompt: systemPrompt)
    }
    
    /// Configuration globale par défaut (pour logging, etc.)
    @available(iOS 26.0, macOS 26.0, watchOS 26.0, tvOS 26.0, *)
    public static var defaultConfiguration: AIMEConfiguration {
        get {
            if #available(iOS 26.0, macOS 26.0, watchOS 26.0, tvOS 26.0, *) {
                return _defaultConfiguration
            } else {
                fatalError("AIME requires iOS 26.0+")
            }
        }
        set {
            if #available(iOS 26.0, macOS 26.0, watchOS 26.0, tvOS 26.0, *) {
                _defaultConfiguration = newValue
            }
        }
    }
    
    @available(iOS 26.0, macOS 26.0, watchOS 26.0, tvOS 26.0, *)
    private static var _defaultConfiguration = AIMEConfiguration()
}

