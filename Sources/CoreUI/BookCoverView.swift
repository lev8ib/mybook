#if canImport(SwiftUI)
import SwiftUI
import UIKit
import CoreModels

public struct BookCoverView: View {
    private let book: Book
    private let imageSize: CGSize

    public init(book: Book, imageSize: CGSize = CGSize(width: 120, height: 180)) {
        self.book = book
        self.imageSize = imageSize
    }

    public var body: some View {
        ZStack(alignment: .bottomLeading) {
            placeholder
                .frame(width: imageSize.width, height: imageSize.height)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(alignment: .topTrailing) {
                    if let price = book.estimatedPrice {
                        PriceBadge(value: price)
                            .offset(x: -8, y: 8)
                    }
                }

            LinearGradient(colors: [.clear, Color.black.opacity(0.65)], startPoint: .center, endPoint: .bottom)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(book.title)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .lineLimit(2)
                Text(book.authors.map(\.name).joined(separator: ", "))
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.8))
            }
            .padding()
        }
        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
    }

    @ViewBuilder
    private var placeholder: some View {
        if let imageName = book.coverImageName, let image = UIImage(named: imageName) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
        } else {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.blue.gradient)
                Text(book.title.prefix(1))
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)
            }
        }
    }
}

struct PriceBadge: View {
    let value: Decimal

    var body: some View {
        Text(value as NSNumber, formatter: formatter)
            .font(.caption.bold())
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(.ultraThinMaterial, in: Capsule())
            .foregroundStyle(.primary)
    }

    private var formatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }
}

#Preview {
    BookCoverView(book: LibraryStore.sampleData().books[0])
}
#endif
