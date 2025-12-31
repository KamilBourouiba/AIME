/*
 Tests pour les action items
 */

import XCTest
@testable import AIME

final class ActionItemTests: XCTestCase {
    
    func testActionItemCreation() {
        let item = ActionItem(
            title: "Test action",
            priority: .high,
            owner: "John Doe",
            dueDate: Date()
        )
        
        XCTAssertEqual(item.title, "Test action")
        XCTAssertEqual(item.priority, .high)
        XCTAssertEqual(item.owner, "John Doe")
        XCTAssertNotNil(item.dueDate)
    }
    
    func testActionItemWithoutOptionalFields() {
        let item = ActionItem(title: "Simple action")
        
        XCTAssertEqual(item.title, "Simple action")
        XCTAssertNil(item.priority)
        XCTAssertNil(item.owner)
        XCTAssertNil(item.dueDate)
    }
    
    func testPriorityEnum() {
        let priorities = Priority.allCases
        XCTAssertGreaterThan(priorities.count, 0)
        
        XCTAssertEqual(Priority.critical.rawValue, "Critique")
        XCTAssertEqual(Priority.high.rawValue, "Élevée")
        XCTAssertEqual(Priority.medium.rawValue, "Moyenne")
        XCTAssertEqual(Priority.low.rawValue, "Basse")
    }
}

