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

    func testShelfIDsForBook() throws {
        let store = LibraryStore.sampleData()
        guard store.books.count > 1 else {
            XCTFail("Недостаточно книг для теста полок")
            return
        }

        let book = store.books[1]
        let shelfIDs = store.shelfIDs(for: book)

        XCTAssertFalse(shelfIDs.isEmpty, "Книга должна находиться хотя бы на одной полке")
        XCTAssertEqual(shelfIDs.count, Set(shelfIDs).count, "Идентификаторы полок не должны дублироваться")

        for shelfID in shelfIDs {
            let containsBook = store.libraries.contains { library in
                library.shelves.contains { shelf in
                    shelf.id == shelfID && shelf.books.contains { $0.book.id == book.id }
                }
            }
            XCTAssertTrue(containsBook, "Полка \(shelfID) должна содержать тестовую книгу")
        }
    }
}
