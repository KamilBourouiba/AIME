/*
 Application d'exemple pour tester AIME
 */

import SwiftUI
import AIME

@main
struct AIMEExampleApp: App {
    init() {
        // Configurer le logging pour voir les messages
        AIME.defaultConfiguration.logging.level = .debug
        AIME.defaultConfiguration.logging.logTokens = true
        
        AIMELogger.shared.info("Application AIME Example démarrée")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

