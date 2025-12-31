/*
 Tests pour la gestion d'erreurs
 */

import XCTest
@testable import AIME

final class ErrorTests: XCTestCase {
    
    func testAIMEErrorDescriptions() {
        let errors: [AIMEError] = [
            .transcriptionNotAuthorized,
            .recordingNotAuthorized,
            .generationModelNotAvailable,
            .textProcessingEmptyInput
        ]
        
        for error in errors {
            XCTAssertNotNil(error.errorDescription)
            XCTAssertFalse(error.errorDescription!.isEmpty)
        }
    }
    
    func testAIMEErrorRecoverySuggestions() {
        let error = AIMEError.transcriptionNotAuthorized
        XCTAssertNotNil(error.recoverySuggestion)
        
        let error2 = AIMEError.generationModelNotAvailable
        XCTAssertNotNil(error2.recoverySuggestion)
    }
    
    func testAIMEErrorFailureReason() {
        let error = AIMEError.transcriptionNotAuthorized
        XCTAssertNotNil(error.failureReason)
    }
}

