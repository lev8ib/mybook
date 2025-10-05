#if canImport(SwiftUI)
import SwiftUI
import UIKit

public struct TagCloudView: View {
    private let tags: [String]

    public init(tags: [String]) {
        self.tags = tags
    }

    public var body: some View {
        GeometryReader { geometry in
            FlexibleView(
                availableWidth: geometry.size.width,
                data: tags,
                spacing: 8,
                alignment: .leading
            ) { tag in
                Text(tag)
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.thickMaterial, in: Capsule())
            }
        }
        .frame(minHeight: 32)
    }
}

struct FlexibleView<Data: Collection, Content: View>: View where Data.Element: Hashable {
    let availableWidth: CGFloat
    let data: Data
    let spacing: CGFloat
    let alignment: HorizontalAlignment
    let content: (Data.Element) -> Content

    init(
        availableWidth: CGFloat,
        data: Data,
        spacing: CGFloat = 8,
        alignment: HorizontalAlignment = .leading,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        self.availableWidth = availableWidth
        self.data = data
        self.spacing = spacing
        self.alignment = alignment
        self.content = content
    }

    var body: some View {
        VStack(alignment: alignment, spacing: spacing) {
            ForEach(Array(computeRows().enumerated()), id: \.offset) { _, row in
                HStack(spacing: spacing) {
                    ForEach(row, id: \.self, content: content)
                }
            }
        }
    }

    private func computeRows() -> [[Data.Element]] {
        var rows: [[Data.Element]] = [[]]
        var currentRowWidth: CGFloat = 0

        for element in data {
            let elementWidth = contentWidth(for: element)
            if currentRowWidth + elementWidth > availableWidth {
                rows.append([element])
                currentRowWidth = elementWidth + spacing
            } else {
                rows[rows.count - 1].append(element)
                currentRowWidth += elementWidth + spacing
            }
        }

        return rows
    }

    private func contentWidth(for element: Data.Element) -> CGFloat {
        let hostingController = UIHostingController(rootView: content(element))
        let size = hostingController.sizeThatFits(in: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 32))
        return size.width
    }
}

#Preview {
    TagCloudView(tags: ["фантастика", "классика", "история", "научпоп", "бизнес", "биографии"])
}
#endif
