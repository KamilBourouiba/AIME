/*
 AIME - Apple Intelligence Made Easy
 Par Kamil Bourouiba
 
 Package principal pour intégrer Apple Intelligence dans vos applications SwiftUI
 */

import Foundation

/// Point d'entrée principal du package AIME
public enum AIME {
    /// Version actuelle du package
    public static let version = "1.0.0"
    
    /// Configuration globale par défaut
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

