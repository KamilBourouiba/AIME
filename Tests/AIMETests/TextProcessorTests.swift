/*
 Tests pour le processeur de texte
 */

import XCTest
@testable import AIME

final class TextProcessorTests: XCTestCase {
    
    func testChunkText() {
        let text = "Premier paragraphe.\n\nDeuxième paragraphe.\n\nTroisième paragraphe."
        let chunks = TextProcessor.chunkText(text, unit: .paragraph)
        
        XCTAssertGreaterThan(chunks.count, 0)
        XCTAssertTrue(chunks.allSatisfy { !$0.isEmpty })
    }
    
    func testIsEmpty() {
        XCTAssertTrue(TextProcessor.isEmpty(""))
        XCTAssertTrue(TextProcessor.isEmpty("   "))
        XCTAssertTrue(TextProcessor.isEmpty("\n\n"))
        XCTAssertFalse(TextProcessor.isEmpty("Hello"))
        XCTAssertFalse(TextProcessor.isEmpty("  Hello  "))
    }
    
    func testEstimateTokenCount() {
        let text = "Hello world"
        let count = TextProcessor.estimateTokenCount(text)
        
        // Estimation approximative: 1 token ≈ 4 caractères
        // "Hello world" = 11 caractères ≈ 2-3 tokens
        XCTAssertGreaterThan(count, 0)
        XCTAssertLessThan(count, 10)
    }
    
    func testTruncate() {
        let text = "This is a very long text that needs to be truncated"
        let truncated = TextProcessor.truncate(text, maxLength: 20)
        
        XCTAssertLessThanOrEqual(truncated.count, 23) // 20 + "..."
        XCTAssertTrue(truncated.hasSuffix("..."))
    }
    
    func testTruncateShortText() {
        let text = "Short"
        let truncated = TextProcessor.truncate(text, maxLength: 20)
        
        XCTAssertEqual(text, truncated)
    }
}

