#if canImport(SwiftUI)
import SwiftUI
import CoreModels

public struct OrganizeFeatureView: View {
    @EnvironmentObject private var libraryStore: LibraryStore
    @State private var selectedStrategy: OrganizationStrategy = .byGenre
    @State private var selectedLibraryID: Library.ID?

    public init() {}

    public var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Picker("Стратегия", selection: $selectedStrategy) {
                    ForEach(OrganizationStrategy.allCases) { strategy in
                        Text(strategy.title).tag(strategy)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                strategyDescription
                    .padding(.horizontal)

                if let library = selectedLibrary {
                    LibraryInsightsView(library: library)
                        .padding(.horizontal)
                    strategyRecommendations(for: library)
                } else {
                    ContentUnavailableView("Добавьте шкаф", systemImage: "books.vertical")
                }

                Spacer()
            }
            .padding(.top)
            .navigationTitle("Навести порядок")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Picker("Шкаф", selection: $selectedLibraryID) {
                            ForEach(libraryStore.libraries) { library in
                                Text(library.name).tag(Optional(library.id))
                            }
                        }
                    } label: {
                        Label("Выбрать шкаф", systemImage: "square.grid.2x2")
                    }
                }
            }
            .onAppear {
                if selectedLibraryID == nil {
                    selectedLibraryID = libraryStore.libraries.first?.id
                }
            }
        }
    }

    private var selectedLibrary: Library? {
        guard let id = selectedLibraryID else { return libraryStore.libraries.first }
        return libraryStore.libraries.first(where: { $0.id == id })
    }

    @ViewBuilder
    private var strategyDescription: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(selectedStrategy.title)
                .font(.title2.bold())
            Text(selectedStrategy.description)
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private func strategyRecommendations(for library: Library) -> some View {
        ScrollView(.horizontal) {
            LazyHStack(alignment: .top, spacing: 24) {
                summaryCard(for: library)
                ForEach(selectedStrategy.steps) { step in
                    VStack(alignment: .leading, spacing: 12) {
                        Label(step.title, systemImage: step.icon)
                            .font(.headline)
                        Text(step.detail)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        if !step.tips.isEmpty {
                            Divider()
                            ForEach(step.tips, id: \.self) { tip in
                                Label(tip, systemImage: "lightbulb")
                                    .font(.footnote)
                            }
                        }
                    }
                    .padding()
                    .frame(width: 320, alignment: .leading)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                }
            }
            .padding(.horizontal)
        }
        .frame(maxHeight: 320)
    }

    @ViewBuilder
    private func summaryCard(for library: Library) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Рекомендованная расстановка", systemImage: "sparkles")
                .font(.headline)
            Text("\(library.shelves.count) полок, \(library.shelves.reduce(0) { $0 + $1.books.count }) книг")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Divider()
            Text(selectedStrategy.dynamicAdvice(for: library))
                .font(.footnote)
        }
        .padding()
        .frame(width: 320, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

public enum OrganizationStrategy: CaseIterable, Identifiable {
    case byGenre
    case byColor
    case byUsage
    case bySize

    public var id: String { title }

    public var title: String {
        switch self {
        case .byGenre:
            return "По жанру"
        case .byColor:
            return "По цвету корешка"
        case .byUsage:
            return "По частоте использования"
        case .bySize:
            return "По размеру"
        }
    }

    public var description: String {
        switch self {
        case .byGenre:
            return "Классифицируйте книги по жанрам и тематическим направлениям, чтобы быстрее находить нужные серии и подборки."
        case .byColor:
            return "Создайте визуальную гармонию, группируя книги по цвету корешков — отлично для открытых стеллажей."
        case .byUsage:
            return "Размещайте часто используемые книги в зоне быстрого доступа, а редкие экземпляры — выше или ниже уровня глаз."
        case .bySize:
            return "Упорядочите книги по высоте и глубине, чтобы оптимально использовать пространство и избежать провисания полок."
        }
    }

    public var steps: [OrganizationStep] {
        switch self {
        case .byGenre:
            return [
                OrganizationStep(title: "Создайте зоны", detail: "Выделите на полках секции для основных жанров вашей коллекции.", icon: "square.grid.3x3")
                    .withTips(["Используйте цветовые маркеры", "Добавьте таблички с названиями жанров"]),
                OrganizationStep(title: "Расположите серии", detail: "Соберите книги серий в один ряд, расположив их по порядку.", icon: "list.number")
                    .withTips(["Поставьте любимые серии на уровень глаз"]),
                OrganizationStep(title: "Создайте подборки", detail: "Сгруппируйте книги для конкретных целей: путешествий, обучения, вдохновения.", icon: "wand.and.stars")
            ]
        case .byColor:
            return [
                OrganizationStep(title: "Выберите палитру", detail: "Разделите книги по оттенкам: холодные, теплые, нейтральные.", icon: "paintpalette")
                    .withTips(["Используйте цвет круга Иттена", "Включите декоративные элементы подходящего цвета"]),
                OrganizationStep(title: "Создайте градиент", detail: "Постройте плавный переход от светлого к темному или наоборот.", icon: "line.diagonal"),
                OrganizationStep(title: "Поддерживайте баланс", detail: "Разбавляйте плотные цветовые блоки нейтральными обложками.", icon: "scale.3d")
            ]
        case .byUsage:
            return [
                OrganizationStep(title: "Проанализируйте частоту", detail: "Определите, какие книги вы берете чаще всего.", icon: "chart.bar")
                    .withTips(["Используйте теги избранного", "Отмечайте прочитанные книги"]),
                OrganizationStep(title: "Выделите зоны доступа", detail: "Полки на уровне глаз для ежедневного чтения, нижние и верхние — для архива.", icon: "rectangle.portrait.on.rectangle.portrait")
                    .withTips(["Используйте декоративные коробки для редких книг"]),
                OrganizationStep(title: "Создайте мобильные подборки", detail: "Соберите актуальные книги в отдельную корзину или на тележку.", icon: "cart")
            ]
        case .bySize:
            return [
                OrganizationStep(title: "Сгруппируйте по высоте", detail: "Расставьте книги от самых высоких к низким или наоборот.", icon: "arrow.up.arrow.down")
                    .withTips(["Контролируйте нагрузку на полку", "Используйте подставки для альбомов"]),
                OrganizationStep(title: "Подберите глубину", detail: "Совмещайте книги схожей глубины, чтобы ряды смотрелись аккуратно.", icon: "ruler")
                    .withTips(["Толстые тома ставьте ближе к краям полки"]),
                OrganizationStep(title: "Добавьте вертикальные стопки", detail: "Используйте горизонтальные стопки для мини-коллекций и аксессуаров.", icon: "cube")
            ]
        }
    }
}

public struct OrganizationStep: Identifiable, Hashable {
    public let id: UUID
    public let title: String
    public let detail: String
    public let icon: String
    public var tips: [String]

    public init(id: UUID = UUID(), title: String, detail: String, icon: String, tips: [String] = []) {
        self.id = id
        self.title = title
        self.detail = detail
        self.icon = icon
        self.tips = tips
    }

    public func withTips(_ tips: [String]) -> OrganizationStep {
        var copy = self
        copy.tips = tips
        return copy
    }
}

private extension OrganizationStrategy {
    func dynamicAdvice(for library: Library) -> String {
        let totalCapacity = library.shelves.reduce(0) { $0 + $1.capacity }
        let totalBooks = library.shelves.reduce(0) { $0 + $1.books.count }
        let utilization = totalCapacity > 0 ? Double(totalBooks) / Double(totalCapacity) : 0
        let utilizationPercent = NumberFormatter.percentFormatter.string(from: utilization as NSNumber) ?? "0%"

        switch self {
        case .byGenre:
            return "Создайте \(library.shelves.count) тематических секций и выделите пространство для новых жанров (заполнено \(utilizationPercent))."
        case .byColor:
            return "Сгруппируйте \(totalBooks) книг по палитрам и используйте декоративные элементы на полках, которые пока пустуют (\(utilizationPercent) заполнения)."
        case .byUsage:
            return "Разместите самые востребованные книги на \(max(1, library.shelves.count / 2)) центральных полках — сейчас библиотека загружена на \(utilizationPercent)."
        case .bySize:
            return "Распределите коллекцию по высоте: начните с самой вместительной полки и учитывайте текущую загрузку (\(utilizationPercent))."
        }
    }
}

struct LibraryInsightsView: View {
    let library: Library

    private var totalCapacity: Int {
        library.shelves.reduce(0) { $0 + $1.capacity }
    }

    private var totalBooks: Int {
        library.shelves.reduce(0) { $0 + $1.books.count }
    }

    private var utilization: Double {
        guard totalCapacity > 0 else { return 0 }
        return Double(totalBooks) / Double(totalCapacity)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Аналитика шкафа \(library.name)")
                .font(.headline)
            HStack(spacing: 24) {
                MetricView(title: "Книг", value: "\(totalBooks)", detail: "Всего экземпляров")
                MetricView(title: "Полок", value: "\(library.shelves.count)", detail: "Активные секции")
                MetricView(title: "Заполнено", value: NumberFormatter.percentFormatter.string(from: utilization as NSNumber) ?? "0%", detail: "Использование объема")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct MetricView: View {
    let title: String
    let value: String
    let detail: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title.uppercased())
                .font(.caption.bold())
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title2.monospacedDigit())
            Text(detail)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

private extension NumberFormatter {
    static let percentFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 0
        return formatter
    }()
}

#Preview {
    OrganizeFeatureView()
        .environmentObject(LibraryStore.sampleData())
}
#endif
