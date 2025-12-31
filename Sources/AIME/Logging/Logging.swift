/*
 Système de logging pour AIME
 */

import Foundation
import OSLog

/// Niveau de logging
public enum LogLevel: Int, Comparable {
    case debug = 0
    case info = 1
    case warning = 2
    case error = 3
    case critical = 4
    
    public static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

/// Entrée de log
public struct LogEntry {
    public let level: LogLevel
    public let message: String
    public let category: String
    public let timestamp: Date
    public let metadata: [String: Any]?
    public let error: Error?
    
    public init(
        level: LogLevel,
        message: String,
        category: String = "AIME",
        metadata: [String: Any]? = nil,
        error: Error? = nil
    ) {
        self.level = level
        self.message = message
        self.category = category
        self.timestamp = Date()
        self.metadata = metadata
        self.error = error
    }
}

/// Logger principal pour AIME
public class AIMELogger {
    public static let shared = AIMELogger()
    
    private var configuration: LoggingConfiguration
    private let osLogger: Logger
    
    private init() {
        self.configuration = AIME.defaultConfiguration.logging
        self.osLogger = Logger(subsystem: "com.kamilbourouiba.AIME", category: "AIME")
    }
    
    /// Mettre à jour la configuration
    public func updateConfiguration(_ config: LoggingConfiguration) {
        self.configuration = config
    }
    
    /// Logger un message
    public func log(
        _ level: LogLevel,
        _ message: String,
        category: String = "AIME",
        metadata: [String: Any]? = nil,
        error: Error? = nil
    ) {
        guard configuration.isEnabled else { return }
        guard level >= configuration.level else { return }
        
        let entry = LogEntry(
            level: level,
            message: message,
            category: category,
            metadata: metadata,
            error: error
        )
        
        // Logger système
        let osLogType: OSLogType
        switch level {
        case .debug:
            osLogType = .debug
        case .info:
            osLogType = .info
        case .warning:
            osLogType = .default
        case .error, .critical:
            osLogType = .error
        }
        
        var logMessage = message
        if let error = error {
            logMessage += " - Erreur: \(error.localizedDescription)"
        }
        if let metadata = metadata, !metadata.isEmpty {
            logMessage += " - Métadonnées: \(metadata)"
        }
        
        osLogger.log(level: osLogType, "\(logMessage)")
        
        // Logger personnalisé
        configuration.customLogger?(entry)
    }
    
    /// Logger un message de debug
    public func debug(_ message: String, category: String = "AIME", metadata: [String: Any]? = nil) {
        log(.debug, message, category: category, metadata: metadata)
    }
    
    /// Logger un message d'information
    public func info(_ message: String, category: String = "AIME", metadata: [String: Any]? = nil) {
        log(.info, message, category: category, metadata: metadata)
    }
    
    /// Logger un avertissement
    public func warning(_ message: String, category: String = "AIME", metadata: [String: Any]? = nil) {
        log(.warning, message, category: category, metadata: metadata)
    }
    
    /// Logger une erreur
    public func error(_ message: String, category: String = "AIME", error: Error? = nil, metadata: [String: Any]? = nil) {
        log(.error, message, category: category, metadata: metadata, error: error)
    }
    
    /// Logger une erreur critique
    public func critical(_ message: String, category: String = "AIME", error: Error? = nil, metadata: [String: Any]? = nil) {
        log(.critical, message, category: category, metadata: metadata, error: error)
    }
}

/// Statistiques de tokens utilisés
public struct TokenUsage {
    public let inputTokens: Int
    public let outputTokens: Int
    public let totalTokens: Int
    public let timestamp: Date
    
    public init(inputTokens: Int, outputTokens: Int) {
        self.inputTokens = inputTokens
        self.outputTokens = outputTokens
        self.totalTokens = inputTokens + outputTokens
        self.timestamp = Date()
    }
}

/// Gestionnaire de tokens
public class TokenTracker {
    public static let shared = TokenTracker()
    
    private var totalInputTokens: Int = 0
    private var totalOutputTokens: Int = 0
    private var usageHistory: [TokenUsage] = []
    
    private init() {}
    
    /// Enregistrer l'utilisation de tokens
    public func recordUsage(inputTokens: Int, outputTokens: Int) {
        totalInputTokens += inputTokens
        totalOutputTokens += outputTokens
        
        let usage = TokenUsage(inputTokens: inputTokens, outputTokens: outputTokens)
        usageHistory.append(usage)
        
        if AIME.defaultConfiguration.logging.logTokens {
            AIMELogger.shared.info(
                "Tokens utilisés - Input: \(inputTokens), Output: \(outputTokens), Total: \(usage.totalTokens)",
                category: "TokenTracker",
                metadata: [
                    "inputTokens": inputTokens,
                    "outputTokens": outputTokens,
                    "totalTokens": usage.totalTokens
                ]
            )
        }
    }
    
    /// Obtenir les statistiques totales
    public func getTotalUsage() -> TokenUsage {
        return TokenUsage(inputTokens: totalInputTokens, outputTokens: totalOutputTokens)
    }
    
    /// Obtenir l'historique d'utilisation
    public func getUsageHistory() -> [TokenUsage] {
        return usageHistory
    }
    
    /// Réinitialiser les statistiques
    public func reset() {
        totalInputTokens = 0
        totalOutputTokens = 0
        usageHistory.removeAll()
    }
}

