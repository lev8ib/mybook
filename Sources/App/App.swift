#if canImport(SwiftUI)
import SwiftUI
import BooksFeature
import LibraryFeature
import OrganizeFeature
import CoreModels
import CoreUI

@main
struct MyBookApp: App {
    @StateObject private var libraryStore = LibraryStore.sampleData()

    var body: some Scene {
        WindowGroup {
            RootSplitView()
                .environmentObject(libraryStore)
        }
        .defaultSize(width: 1280, height: 960)
    }
}
#else
@main
struct MyBookApp {
    static func main() {
        fatalError("SwiftUI недоступен в этой среде")
    }
}
#endif
