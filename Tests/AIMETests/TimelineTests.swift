/*
 Tests pour les timelines
 */

import XCTest
@testable import AIME

final class TimelineTests: XCTestCase {
    
    func testTimelineItemCreation() {
        let item = TimelineItem(
            title: "Project milestone",
            date: "2024-12-31",
            owner: "Jane Doe",
            status: "in progress",
            priority: .high
        )
        
        XCTAssertEqual(item.title, "Project milestone")
        XCTAssertEqual(item.date, "2024-12-31")
        XCTAssertEqual(item.owner, "Jane Doe")
        XCTAssertEqual(item.status, "in progress")
        XCTAssertEqual(item.priority, .high)
    }
    
    func testTimelineCreation() {
        let items = [
            TimelineItem(title: "Item 1", date: "2024-01-01"),
            TimelineItem(title: "Item 2", date: "2024-02-01")
        ]
        
        let timeline = Timeline(
            items: items,
            extractionNotes: "Test notes"
        )
        
        XCTAssertEqual(timeline.items.count, 2)
        XCTAssertEqual(timeline.extractionNotes, "Test notes")
    }
    
    func testTimelineWithoutNotes() {
        let items = [TimelineItem(title: "Item", date: "2024-01-01")]
        let timeline = Timeline(items: items)
        
        XCTAssertEqual(timeline.items.count, 1)
        XCTAssertNil(timeline.extractionNotes)
    }
}

