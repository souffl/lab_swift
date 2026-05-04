import Foundation

indirect enum BDUIJSONValue: Codable {
    case null
    case bool(Bool)
    case number(Double)
    case string(String)
    case array([BDUIJSONValue])
    case object([String: BDUIJSONValue])

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if container.decodeNil() {
            self = .null
            return
        }
        if let bool = try? container.decode(Bool.self) {
            self = .bool(bool)
            return
        }
        if let string = try? container.decode(String.self) {
            self = .string(string)
            return
        }
        if let number = try? container.decode(Double.self) {
            self = .number(number)
            return
        }
        if let array = try? container.decode([BDUIJSONValue].self) {
            self = .array(array)
            return
        }
        if let object = try? container.decode([String: BDUIJSONValue].self) {
            self = .object(object)
            return
        }

        throw DecodingError.dataCorruptedError(
            in: container,
            debugDescription: "Unsupported JSON value"
        )
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .null:
            try container.encodeNil()
        case .bool(let value):
            try container.encode(value)
        case .number(let value):
            try container.encode(value)
        case .string(let value):
            try container.encode(value)
        case .array(let value):
            try container.encode(value)
        case .object(let value):
            try container.encode(value)
        }
    }

    var stringValue: String? {
        switch self {
        case .string(let value):
            return value
        case .number(let value):
            if value.rounded() == value, abs(value) < Double(Int.max) {
                return String(Int(value))
            }
            return String(value)
        case .bool(let value):
            return String(value)
        case .null:
            return ""
        default:
            return nil
        }
    }

    var objectValue: [String: BDUIJSONValue]? {
        guard case .object(let value) = self else {
            return nil
        }
        return value
    }
}
