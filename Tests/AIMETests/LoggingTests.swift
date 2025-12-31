/*
 Tests pour le système de logging
 */

import XCTest
@testable import AIME

final class LoggingTests: XCTestCase {
    
    func testLogLevelComparison() {
        XCTAssertTrue(LogLevel.debug < LogLevel.info)
        XCTAssertTrue(LogLevel.info < LogLevel.warning)
        XCTAssertTrue(LogLevel.warning < LogLevel.error)
        XCTAssertTrue(LogLevel.error < LogLevel.critical)
    }
    
    func testLogEntryCreation() {
        let entry = LogEntry(
            level: .info,
            message: "Test message",
            category: "Test",
            metadata: ["key": "value"],
            error: nil
        )
        
        XCTAssertEqual(entry.level, .info)
        XCTAssertEqual(entry.message, "Test message")
        XCTAssertEqual(entry.category, "Test")
        XCTAssertNotNil(entry.metadata)
        XCTAssertNil(entry.error)
    }
    
    func testTokenUsage() {
        let usage = TokenUsage(inputTokens: 100, outputTokens: 50)
        
        XCTAssertEqual(usage.inputTokens, 100)
        XCTAssertEqual(usage.outputTokens, 50)
        XCTAssertEqual(usage.totalTokens, 150)
    }
    
    func testTokenTracker() {
        TokenTracker.shared.reset()
        
        TokenTracker.shared.recordUsage(inputTokens: 100, outputTokens: 50)
        TokenTracker.shared.recordUsage(inputTokens: 200, outputTokens: 100)
        
        let total = TokenTracker.shared.getTotalUsage()
        XCTAssertEqual(total.inputTokens, 300)
        XCTAssertEqual(total.outputTokens, 150)
        XCTAssertEqual(total.totalTokens, 450)
        
        let history = TokenTracker.shared.getUsageHistory()
        XCTAssertEqual(history.count, 2)
        
        TokenTracker.shared.reset()
        let resetTotal = TokenTracker.shared.getTotalUsage()
        XCTAssertEqual(resetTotal.totalTokens, 0)
    }
    
    func testLoggerWithDisabledLogging() {
        let config = LoggingConfiguration(isEnabled: false)
        AIMELogger.shared.updateConfiguration(config)
        
        // Le logger ne devrait pas logger quand désactivé
        AIMELogger.shared.info("This should not be logged")
        
        // Réactiver pour les autres tests
        AIMELogger.shared.updateConfiguration(LoggingConfiguration())
    }
}

