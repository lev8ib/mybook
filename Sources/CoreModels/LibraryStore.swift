import Foundation
#if canImport(Combine)
import Combine
#endif

public final class LibraryStore: ObservableObject {
    @Published public var books: [Book]
    @Published public var libraries: [Library]

    public init(books: [Book], libraries: [Library]) {
        self.books = books
        self.libraries = libraries
    }

    public func placements(for book: Book) -> [BookPlacement] {
        libraries.flatMap { library in
            library.shelves.flatMap { shelf in
                shelf.books.filter { $0.book.id == book.id }
            }
        }
    }

    public func move(bookPlacement: BookPlacement, to shelfID: Shelf.ID, position: Int) {
        for index in libraries.indices {
            if let shelfIndex = libraries[index].shelves.firstIndex(where: { $0.id == shelfID }) {
                libraries[index].shelves[shelfIndex].books.removeAll { $0.id == bookPlacement.id }
                var updated = bookPlacement
                updated.position = position
                libraries[index].shelves[shelfIndex].books.append(updated)
                libraries[index].shelves[shelfIndex].books.sort { $0.position < $1.position }
#if canImport(Combine)
                objectWillChange.send()
#endif
                return
            }
        }
    }
}

public extension LibraryStore {
    static func sampleData() -> LibraryStore {
        let sampleBooks: [Book] = [
            Book(
                title: "Атлант расправил плечи",
                authors: [Author(name: "Айн Рэнд")],
                edition: Edition(publisher: "АСТ", year: 2020, isbn: "978-5-17-118366-7", language: "ru"),
                dimensions: Dimensions(width: 15.5, height: 24.0, depth: 5.5, weight: 950),
                estimatedPrice: 1999,
                genres: ["Философия", "Роман"],
                notes: "Коллекционное издание",
                coverImageName: "atlas_shrugged"
            ),
            Book(
                title: "Sapiens: Краткая история человечества",
                authors: [Author(name: "Юваль Ной Харари")],
                edition: Edition(publisher: "Синдбад", year: 2021, isbn: "978-5-00159-306-0", language: "ru"),
                dimensions: Dimensions(width: 16.0, height: 24.0, depth: 4.0, weight: 870),
                estimatedPrice: 1490,
                genres: ["История", "Научпоп"],
                notes: "Любимое издание",
                coverImageName: "sapiens"
            ),
            Book(
                title: "Clean Code",
                authors: [Author(name: "Robert C. Martin", role: "Author")],
                edition: Edition(publisher: "Prentice Hall", year: 2018, isbn: "9780132350884", language: "en"),
                dimensions: Dimensions(width: 17.0, height: 23.5, depth: 3.0, weight: 650),
                estimatedPrice: 3290,
                genres: ["Программирование"],
                notes: "Рабочий экземпляр",
                coverImageName: "clean_code"
            )
        ]

        let philosophyShelf = Shelf(
            name: "Философия",
            capacity: 25,
            books: [
                BookPlacement(book: sampleBooks[0], position: 1),
                BookPlacement(book: sampleBooks[1], position: 2)
            ]
        )

        let scienceShelf = Shelf(
            name: "Научпоп",
            capacity: 30,
            books: [
                BookPlacement(book: sampleBooks[1], position: 1)
            ]
        )

        let itShelf = Shelf(
            name: "IT",
            capacity: 40,
            books: [
                BookPlacement(book: sampleBooks[2], position: 1, orientation: .frontCover)
            ]
        )

        let libraries: [Library] = [
            Library(name: "Главный шкаф", description: "Большой дубовый шкаф в гостиной", shelves: [philosophyShelf, scienceShelf, itShelf])
        ]

        return LibraryStore(books: sampleBooks, libraries: libraries)
    }
}
