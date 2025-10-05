#if canImport(SwiftUI)
import SwiftUI
import CoreModels

public struct LibraryFeatureView: View {
    @EnvironmentObject private var libraryStore: LibraryStore
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    @State private var selectedLibraryID: Library.ID?
    @State private var selectedShelfID: Shelf.ID?

    public init() {}

    public var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            if libraryStore.libraries.isEmpty {
                ContentUnavailableView("Добавьте шкаф", systemImage: "books.vertical")
            } else {
                List(selection: $selectedLibraryID) {
                    ForEach(libraryStore.libraries) { library in
                        VStack(alignment: .leading) {
                            Text(library.name)
                                .font(.headline)
                            if !library.description.isEmpty {
                                Text(library.description)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .tag(Optional(library.id))
                    }
                }
                .navigationTitle("Шкафы")
            }
        } content: {
            if let library = selectedLibrary, !library.shelves.isEmpty {
                List(selection: $selectedShelfID) {
                    ForEach(library.shelves) { shelf in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(shelf.name)
                                .font(.title3)
                            ProgressView(value: Double(shelf.books.count), total: Double(shelf.capacity)) {
                                Text("\(shelf.books.count) / \(shelf.capacity) книг")
                                    .font(.caption)
                            }
                            ShelfVisualizationView(shelf: shelf)
                                .frame(height: 120)
                        }
                        .padding(.vertical, 8)
                        .tag(Optional(shelf.id))
                    }
                }
                .navigationTitle(library.name)
            } else {
                ContentUnavailableView("Выберите шкаф", systemImage: "books.vertical")
            }
        } detail: {
            if let shelf = selectedShelf {
                ShelfDetailView(shelf: shelf)
            } else {
                ContentUnavailableView("Выберите полку", systemImage: "rectangle.split.3x1")
            }
        }
        .task { initializeSelectionsIfNeeded() }
        .onChange(of: libraryStore.libraries) { _ in
            guard !libraryStore.libraries.isEmpty else {
                selectedLibraryID = nil
                selectedShelfID = nil
                return
            }

            if let selectedLibraryID, !libraryStore.libraries.contains(where: { $0.id == selectedLibraryID }) {
                self.selectedLibraryID = nil
            }

            if let selectedShelfID, !availableShelves.contains(where: { $0.id == selectedShelfID }) {
                self.selectedShelfID = nil
            }

            initializeSelectionsIfNeeded()
        }
        .onChange(of: selectedLibraryID) { _ in
            guard let library = selectedLibrary else {
                selectedShelfID = nil
                return
            }

            if let selectedShelfID, !library.shelves.contains(where: { $0.id == selectedShelfID }) {
                selectedShelfID = nil
            }

            if selectedShelfID == nil {
                selectedShelfID = library.shelves.first?.id
            }
        }
    }

    private var selectedLibrary: Library? {
        guard let id = selectedLibraryID else { return libraryStore.libraries.first }
        return libraryStore.libraries.first(where: { $0.id == id })
    }

    private var selectedShelf: Shelf? {
        guard let library = selectedLibrary else { return nil }
        guard let id = selectedShelfID else { return library.shelves.first }
        return library.shelves.first(where: { $0.id == id })
    }

    private var availableShelves: [Shelf] {
        selectedLibrary?.shelves ?? libraryStore.libraries.first?.shelves ?? []
    }

    private func initializeSelectionsIfNeeded() {
        if selectedLibraryID == nil {
            selectedLibraryID = libraryStore.libraries.first?.id
        }

        if selectedShelfID == nil {
            selectedShelfID = availableShelves.first?.id
        }
    }
}

struct ShelfVisualizationView: View {
    let shelf: Shelf

    var body: some View {
        GeometryReader { proxy in
            let totalWidth = proxy.size.width
            let spacing: CGFloat = 4
            let bookWidth = (totalWidth - CGFloat(max(shelf.books.count - 1, 0)) * spacing) / CGFloat(max(shelf.capacity, 1))

            HStack(spacing: spacing) {
                ForEach(0..<shelf.capacity, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(color(for: index))
                        .frame(width: max(bookWidth, 12))
                }
            }
            .frame(height: proxy.size.height)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(Color.secondary.opacity(0.3), lineWidth: 1)
            )
        }
    }

    private func color(for index: Int) -> AnyShapeStyle {
        if index < shelf.books.count {
            let placement = shelf.books.sorted(by: { $0.position < $1.position })[index]
            switch placement.orientation {
            case .spineOut:
                return AnyShapeStyle(Color.blue.gradient)
            case .frontCover:
                return AnyShapeStyle(Color.orange.gradient)
            case .stacked:
                return AnyShapeStyle(Color.green.gradient)
            }
        }
        return AnyShapeStyle(Color.secondary.opacity(0.2))
    }
}

struct ShelfDetailView: View {
    let shelf: Shelf

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(shelf.name)
                    .font(.largeTitle.bold())
                Text("Вместимость: \(shelf.capacity)")
                    .font(.headline)
                ShelfVisualizationView(shelf: shelf)
                    .frame(height: 160)

                if shelf.books.isEmpty {
                    ContentUnavailableView("Пока нет книг", systemImage: "questionmark.book")
                } else {
                    ForEach(shelf.books.sorted(by: { $0.position < $1.position })) { placement in
                        BookPlacementRow(placement: placement)
                            .padding()
                            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                }
            }
            .padding()
        }
        .background(Color(uiColor: .secondarySystemBackground))
    }
}

struct BookPlacementRow: View {
    let placement: BookPlacement

    var body: some View {
        HStack(spacing: 16) {
            Text("#\(placement.position)")
                .font(.title3.monospacedDigit())
                .frame(width: 48)
            VStack(alignment: .leading, spacing: 6) {
                Text(placement.book.title)
                    .font(.headline)
                Text(placement.book.authors.map(\.name).joined(separator: ", "))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(placement.orientation.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
    }
}

#Preview {
    LibraryFeatureView()
        .environmentObject(LibraryStore.sampleData())
}
#endif
