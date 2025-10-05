#if canImport(SwiftUI)
import SwiftUI
import BooksFeature
import LibraryFeature
import OrganizeFeature
import CoreModels
import CoreUI

struct RootSplitView: View {
    enum SidebarItem: String, CaseIterable, Identifiable {
        case books
        case library
        case organize

        var id: Self { self }

        var title: String {
            switch self {
            case .books:
                return "Мои книги"
            case .library:
                return "Моя библиотека"
            case .organize:
                return "Навести порядок"
            }
        }

        var icon: String {
            switch self {
            case .books:
                return "books.vertical"
            case .library:
                return "books.vertical.fill"
            case .organize:
                return "square.grid.3x2"
            }
        }
    }

    @EnvironmentObject private var libraryStore: LibraryStore
    @State private var selection: SidebarItem? = .books

    var body: some View {
        NavigationSplitView {
            List(SidebarItem.allCases, selection: $selection) { item in
                Label(item.title, systemImage: item.icon)
            }
            .navigationTitle("Домашняя библиотека")
        } detail: {
            switch selection ?? .books {
            case .books:
                BooksFeatureView()
                    .environmentObject(libraryStore)
            case .library:
                LibraryFeatureView()
                    .environmentObject(libraryStore)
            case .organize:
                OrganizeFeatureView()
                    .environmentObject(libraryStore)
            }
        }
    }
}

#Preview {
    RootSplitView()
        .environmentObject(LibraryStore.sampleData())
}
#endif
