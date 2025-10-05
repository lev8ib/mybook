import Foundation

public struct Book: Identifiable, Hashable, Codable {
    public var id: UUID
    public var title: String
    public var authors: [Author]
    public var edition: Edition
    public var dimensions: Dimensions
    public var estimatedPrice: Decimal?
    public var genres: [String]
    public var notes: String
    public var coverImageName: String?

    public init(
        id: UUID = UUID(),
        title: String,
        authors: [Author],
        edition: Edition,
        dimensions: Dimensions,
        estimatedPrice: Decimal? = nil,
        genres: [String] = [],
        notes: String = "",
        coverImageName: String? = nil
    ) {
        self.id = id
        self.title = title
        self.authors = authors
        self.edition = edition
        self.dimensions = dimensions
        self.estimatedPrice = estimatedPrice
        self.genres = genres
        self.notes = notes
        self.coverImageName = coverImageName
    }
}

public struct Author: Hashable, Codable {
    public var name: String
    public var role: String

    public init(name: String, role: String = "Автор") {
        self.name = name
        self.role = role
    }
}

public struct Edition: Hashable, Codable {
    public var publisher: String
    public var year: Int
    public var isbn: String
    public var language: String

    public init(publisher: String, year: Int, isbn: String, language: String) {
        self.publisher = publisher
        self.year = year
        self.isbn = isbn
        self.language = language
    }
}

public struct Dimensions: Hashable, Codable {
    public var width: Double
    public var height: Double
    public var depth: Double
    public var weight: Double
    public var unit: LengthUnit

    public init(width: Double, height: Double, depth: Double, weight: Double, unit: LengthUnit = .centimeters) {
        self.width = width
        self.height = height
        self.depth = depth
        self.weight = weight
        self.unit = unit
    }

    public var formattedDescription: String {
#if canImport(UIKit) || canImport(AppKit)
        let measurementFormatter = MeasurementFormatter()
        measurementFormatter.unitStyle = .medium
        let widthMeasurement = Measurement(value: width, unit: unit.unitLength)
        let heightMeasurement = Measurement(value: height, unit: unit.unitLength)
        let depthMeasurement = Measurement(value: depth, unit: unit.unitLength)
        measurementFormatter.unitOptions = .providedUnit
        let weightFormatter = MeasurementFormatter()
        weightFormatter.unitStyle = .short
        weightFormatter.unitOptions = .providedUnit
        let weightMeasurement = Measurement(value: weight, unit: UnitMass.grams)
        return "\(measurementFormatter.string(from: widthMeasurement)) × \(measurementFormatter.string(from: heightMeasurement)) × \(measurementFormatter.string(from: depthMeasurement)), \(weightFormatter.string(from: weightMeasurement))"
#else
        let dimensionsString = String(format: "%.1f × %.1f × %.1f %@", width, height, depth, unit.localizedName)
        let weightString = String(format: "%.0f г", weight)
        return "\(dimensionsString), \(weightString)"
#endif
    }
}

public enum LengthUnit: String, Codable, CaseIterable {
    case centimeters
    case millimeters
    case inches

    var unitLength: UnitLength {
        switch self {
        case .centimeters:
            return .centimeters
        case .millimeters:
            return .millimeters
        case .inches:
            return .inches
        }
    }

    var localizedName: String {
        switch self {
        case .centimeters:
            return "см"
        case .millimeters:
            return "мм"
        case .inches:
            return "дюйм"
        }
    }
}
