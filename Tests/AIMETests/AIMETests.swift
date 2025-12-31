/*
 Tests unitaires pour AIME
 */

import XCTest
@testable import AIME

final class AIMETests: XCTestCase {
    
    func testAIMEVersion() {
        XCTAssertEqual(AIME.version, "1.0.0")
    }
    
    func testDefaultConfiguration() {
        let config = AIME.defaultConfiguration
        XCTAssertNotNil(config)
        XCTAssertEqual(config.languageModel.useCase, .general)
        XCTAssertEqual(config.logging.level, .info)
    }
    
    func testConfigurationCustomization() {
        var config = AIMEConfiguration()
        config.logging.level = .debug
        config.logging.logTokens = false
        
        XCTAssertEqual(config.logging.level, .debug)
        XCTAssertFalse(config.logging.logTokens)
    }
}

