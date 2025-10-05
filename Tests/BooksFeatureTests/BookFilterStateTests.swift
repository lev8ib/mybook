import XCTest
@testable import BooksFeature
import CoreModels

final class BookFilterStateTests: XCTestCase {
    private var store: LibraryStore!

    override func setUp() {
        super.setUp()
        store = LibraryStore.sampleData()
    }

    func testEmptyFiltersReturnAllBooks() {
        let filters = BookFilterState()
        XCTAssertEqual(filters.filteredBooks(in: store).count, store.books.count)
    }

    func testSearchFiltersByTitle() {
        var filters = BookFilterState()
        filters.searchText = "clean"

        let results = filters.filteredBooks(in: store)

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.title, "Clean Code")
    }

    func testGenreFilterNarrowsResults() {
        var filters = BookFilterState()
        filters.setGenre("Научпоп", isSelected: true)

        let results = filters.filteredBooks(in: store)

        XCTAssertFalse(results.isEmpty)
        XCTAssertTrue(results.allSatisfy { $0.genres.contains("Научпоп") })
    }

    func testShelfFilterUsesStoreLookup() throws {
        guard let referenceBook = store.books.first else {
            XCTFail("Нет книг для теста")
            return
        }

        let shelfIDs = store.shelfIDs(for: referenceBook)
        guard let shelfID = shelfIDs.first else {
            XCTFail("У книги не обнаружены полки")
            return
        }

        var filters = BookFilterState()
        filters.setShelf(shelfID, isSelected: true)

        let results = filters.filteredBooks(in: store)

        XCTAssertTrue(results.contains(where: { $0.id == referenceBook.id }))

        filters.setShelf(shelfID, isSelected: false)
        filters.setShelf(UUID(), isSelected: true)

        let unmatchedResults = filters.filteredBooks(in: store)
        XCTAssertTrue(unmatchedResults.isEmpty)
    }
}
