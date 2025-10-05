#if canImport(SwiftUI)
import SwiftUI
import CoreModels
import CoreUI

public struct BooksFeatureView: View {
    @EnvironmentObject private var libraryStore: LibraryStore
    @State private var searchText: String = ""
    @State private var selectedGenreFilters: Set<String> = []
    @State private var selectedShelfFilters: Set<Shelf.ID> = []
    @State private var selectedBook: Book?

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView(.horizontal) {
                LazyHGrid(rows: [GridItem(.fixed(260))], spacing: 24) {
                    ForEach(filteredBooks) { book in
                        VStack(alignment: .leading, spacing: 16) {
                            BookCoverView(book: book, imageSize: CGSize(width: 220, height: 320))
                                .onTapGesture {
                                    selectedBook = book
                                }

                            VStack(alignment: .leading, spacing: 8) {
                                Text(book.title)
                                    .font(.title3.weight(.semibold))
                                Text(book.authors.map(\.name).joined(separator: ", "))
                                    .font(.headline)
                                    .foregroundStyle(.secondary)
                                TagCloudView(tags: book.genres)
                            }
                        }
                        .frame(width: 240, alignment: .leading)
                    }
                }
                .padding(32)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .searchable(text: $searchText, placement: .toolbar, prompt: Text("Поиск по названию, автору или жанру"))
            .navigationTitle("Мои книги")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Section("Жанры") {
                            ForEach(allGenres, id: \.self) { genre in
                                Toggle(genre, isOn: Binding(
                                    get: { selectedGenreFilters.contains(genre) },
                                    set: { newValue in
                                        if newValue {
                                            selectedGenreFilters.insert(genre)
                                        } else {
                                            selectedGenreFilters.remove(genre)
                                        }
                                    }
                                ))
                            }
                        }
                        Section("Полки") {
                            ForEach(allShelfFilters, id: \.id) { shelf in
                                Toggle(shelf.title, isOn: Binding(
                                    get: { selectedShelfFilters.contains(shelf.id) },
                                    set: { newValue in
                                        if newValue {
                                            selectedShelfFilters.insert(shelf.id)
                                        } else {
                                            selectedShelfFilters.remove(shelf.id)
                                        }
                                    }
                                ))
                            }
                        }
                    } label: {
                        Label("Фильтры", systemImage: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .sheet(item: $selectedBook) { book in
                BookDetailView(book: book)
            }
        }
    }

    private var filteredBooks: [Book] {
        libraryStore.books.filter { book in
            matchesSearch(book: book) && matchesFilters(book: book)
        }
    }

    private func matchesSearch(book: Book) -> Bool {
        guard !searchText.isEmpty else { return true }
        let lowercasedQuery = searchText.lowercased()
        let textToSearch = [
            book.title,
            book.authors.map(\.name).joined(separator: " "),
            book.genres.joined(separator: " ")
        ].joined(separator: " ").lowercased()
        return textToSearch.contains(lowercasedQuery)
    }

    private func matchesFilters(book: Book) -> Bool {
        let genreMatches: Bool
        if selectedGenreFilters.isEmpty {
            genreMatches = true
        } else {
            genreMatches = !selectedGenreFilters.isDisjoint(with: Set(book.genres))
        }

        let shelfMatches: Bool
        if selectedShelfFilters.isEmpty {
            shelfMatches = true
        } else {
            let bookShelfIDs = Set(libraryStore.shelfIDs(for: book))
            shelfMatches = !selectedShelfFilters.isDisjoint(with: bookShelfIDs)
        }

        return genreMatches && shelfMatches
    }

    private var allGenres: [String] {
        Set(libraryStore.books.flatMap(\.$genres)).sorted()
    }

    private var allShelfFilters: [(id: Shelf.ID, title: String)] {
        libraryStore.libraries.flatMap { library in
            library.shelves.map { shelf in
                (id: shelf.id, title: "\(library.name) · \(shelf.name)")
            }
        }
        .sorted(by: { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending })
    }
}

struct BookDetailView: View {
    let book: Book

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                BookCoverView(book: book, imageSize: CGSize(width: 320, height: 480))
                    .frame(maxWidth: .infinity)
                    .padding(.top)

                VStack(alignment: .leading, spacing: 12) {
                    GroupBox("Издание") {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Издатель: \(book.edition.publisher)")
                            Text("Год: \(book.edition.year)")
                            Text("ISBN: \(book.edition.isbn)")
                            Text("Язык: \(book.edition.language.uppercased())")
                        }
                    }

                    GroupBox("Габариты и вес") {
                        Text(book.dimensions.formattedDescription)
                    }

                    if let price = book.estimatedPrice {
                        GroupBox("Оценочная стоимость") {
                            Text(priceFormatter.string(from: price as NSNumber) ?? "—")
                        }
                    }

                    if !book.notes.isEmpty {
                        GroupBox("Заметки") {
                            Text(book.notes)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .presentationDetents([.fraction(0.6), .large])
        .presentationDragIndicator(.visible)
        .background(Color(uiColor: .systemGroupedBackground))
    }
}

private let priceFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.locale = Locale(identifier: "ru_RU")
    return formatter
}()

#Preview {
    BooksFeatureView()
        .environmentObject(LibraryStore.sampleData())
}
#endif
