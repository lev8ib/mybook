import Foundation
import CoreModels

public struct BookFilterState: Equatable {
    public var searchText: String
    public var selectedGenres: Set<String>
    public var selectedShelves: Set<Shelf.ID>

    public init(
        searchText: String = "",
        selectedGenres: Set<String> = [],
        selectedShelves: Set<Shelf.ID> = []
    ) {
        self.searchText = searchText
        self.selectedGenres = selectedGenres
        self.selectedShelves = selectedShelves
    }

    public mutating func setGenre(_ genre: String, isSelected: Bool) {
        if isSelected {
            selectedGenres.insert(genre)
        } else {
            selectedGenres.remove(genre)
        }
    }

    public mutating func setShelf(_ shelfID: Shelf.ID, isSelected: Bool) {
        if isSelected {
            selectedShelves.insert(shelfID)
        } else {
            selectedShelves.remove(shelfID)
        }
    }

    public mutating func reset() {
        searchText = ""
        selectedGenres.removeAll()
        selectedShelves.removeAll()
    }

    public func filteredBooks(in store: LibraryStore) -> [Book] {
        store.books.filter { matches(book: $0, in: store) }
    }

    public func matches(book: Book, in store: LibraryStore) -> Bool {
        matchesSearch(for: book) && matchesGenres(for: book) && matchesShelves(for: book, store: store)
    }

    private func matchesSearch(for book: Book) -> Bool {
        let normalizedQuery = searchText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        guard !normalizedQuery.isEmpty else { return true }

        let textToSearch = [
            book.title,
            book.authors.map(\.name).joined(separator: " "),
            book.genres.joined(separator: " ")
        ].joined(separator: " ").lowercased()

        return textToSearch.contains(normalizedQuery)
    }

    private func matchesGenres(for book: Book) -> Bool {
        guard !selectedGenres.isEmpty else { return true }
        return !selectedGenres.isDisjoint(with: Set(book.genres))
    }

    private func matchesShelves(for book: Book, store: LibraryStore) -> Bool {
        guard !selectedShelves.isEmpty else { return true }
        let bookShelfIDs = Set(store.shelfIDs(for: book))
        return !selectedShelves.isDisjoint(with: bookShelfIDs)
    }
}
