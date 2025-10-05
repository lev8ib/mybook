import XCTest
@testable import CoreModels

final class CoreModelsTests: XCTestCase {
    func testSampleDataHasLibrariesAndBooks() throws {
        let store = LibraryStore.sampleData()
        XCTAssertFalse(store.books.isEmpty, "Должны существовать примерные книги")
        XCTAssertFalse(store.libraries.isEmpty, "Должен существовать примерный шкаф")
        XCTAssertGreaterThan(store.libraries.first?.shelves.count ?? 0, 0, "У шкафа должны быть полки")
    }

    func testPlacementsForBook() throws {
        let store = LibraryStore.sampleData()
        guard let book = store.books.first else {
            XCTFail("Нет книг в примерах")
            return
        }

        let placements = store.placements(for: book)
        XCTAssertFalse(placements.isEmpty)
        XCTAssertTrue(placements.allSatisfy { $0.book.id == book.id })
    }

}
