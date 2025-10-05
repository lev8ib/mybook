import Foundation

public struct Library: Identifiable, Codable, Hashable {
    public var id: UUID
    public var name: String
    public var description: String
    public var shelves: [Shelf]

    public init(id: UUID = UUID(), name: String, description: String = "", shelves: [Shelf]) {
        self.id = id
        self.name = name
        self.description = description
        self.shelves = shelves
    }
}

public struct Shelf: Identifiable, Codable, Hashable {
    public var id: UUID
    public var name: String
    public var capacity: Int
    public var books: [BookPlacement]

    public init(id: UUID = UUID(), name: String, capacity: Int, books: [BookPlacement] = []) {
        self.id = id
        self.name = name
        self.capacity = capacity
        self.books = books
    }
}

public struct BookPlacement: Identifiable, Codable, Hashable {
    public var id: UUID
    public var book: Book
    public var position: Int
    public var orientation: Orientation

    public init(id: UUID = UUID(), book: Book, position: Int, orientation: Orientation = .spineOut) {
        self.id = id
        self.book = book
        self.position = position
        self.orientation = orientation
    }
}

public enum Orientation: String, Codable, CaseIterable {
    case spineOut = "Корешок наружу"
    case frontCover = "Обложка наружу"
    case stacked = "Стопкой"
}
