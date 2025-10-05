#if canImport(SwiftUI)
import SwiftUI
import CoreModels
import CoreUI

public struct BooksFeatureView: View {
    @EnvironmentObject private var libraryStore: LibraryStore
    @State private var filters = BookFilterState()
    @State private var selectedBook: Book?

    public init() {}

    public var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()

                if filteredBooks.isEmpty {
                    emptyStateView
                } else {
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
                }
            }
            .searchable(text: $filters.searchText, placement: .toolbar, prompt: Text("Поиск по названию, автору или жанру"))
            .navigationTitle("Мои книги")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Section("Жанры") {
                            ForEach(allGenres, id: \.self) { genre in
                                Toggle(genre, isOn: genreBinding(for: genre))
                            }
                        }
                        Section("Полки") {
                            ForEach(allShelfFilters) { shelf in
                                Toggle(shelf.title, isOn: shelfBinding(for: shelf.id))
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

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "books.vertical")
                .resizable()
                .scaledToFit()
                .frame(width: 96, height: 96)
                .foregroundStyle(.quaternary)

            Text("Нет книг по заданным условиям")
                .font(.title2.weight(.semibold))

            Text("Измените параметры поиска или фильтров, чтобы увидеть доступные книги.")
                .multilineTextAlignment(.center)
                .font(.body)
                .foregroundStyle(.secondary)
                .frame(maxWidth: 320)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var filteredBooks: [Book] {
        filters.filteredBooks(in: libraryStore)
    }

    private var allGenres: [String] {
        Set(libraryStore.books.flatMap(\.genres)).sorted()
    }

    private var allShelfFilters: [ShelfFilterOption] {
        libraryStore.libraries.flatMap { library in
            library.shelves.map { shelf in
                ShelfFilterOption(
                    id: shelf.id,
                    libraryName: library.name,
                    shelfName: shelf.name
                )
            }
        }
        .sorted(by: { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending })
    }

    private func genreBinding(for genre: String) -> Binding<Bool> {
        Binding(
            get: { filters.selectedGenres.contains(genre) },
            set: { filters.setGenre(genre, isSelected: $0) }
        )
    }

    private func shelfBinding(for shelfID: Shelf.ID) -> Binding<Bool> {
        Binding(
            get: { filters.selectedShelves.contains(shelfID) },
            set: { filters.setShelf(shelfID, isSelected: $0) }
        )
    }
}

private struct ShelfFilterOption: Identifiable, Hashable {
    let id: Shelf.ID
    let libraryName: String
    let shelfName: String

    var title: String {
        "\(libraryName) · \(shelfName)"
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
