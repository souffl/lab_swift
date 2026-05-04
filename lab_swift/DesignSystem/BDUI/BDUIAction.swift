//
//  BDUIAction.swift
//  lab_swift
//
//  Created by Екатерина Берендюгина on 30.04.2026.
//

enum BDUIAction: Decodable, Equatable {
    case submit
    case print(String)
    case deeplink(String)
    case back
    case reload
    case none

    private enum DiscriminatorKey: String, CodingKey {
        case type
        case context
        case url
    }

    private enum Kind: String, Decodable {
        case submit
        case print
        case deeplink
        case back
        case reload
        case none
    }

    init(from decoder: Decoder) throws {
        if let single = try? decoder.singleValueContainer(), let raw = try? single.decode(String.self) {
            switch raw {
            case "submit":
                self = .submit
            case "print":
                self = .print("")
            case "back":
                self = .back
            case "reload":
                self = .reload
            case "none":
                self = .none
            default:
                self = .none
            }
            return
        }

        let container = try decoder.container(keyedBy: DiscriminatorKey.self)
        let kind = try container.decode(Kind.self, forKey: .type)
        switch kind {
        case .submit:
            self = .submit
        case .print:
            let context = try container.decodeIfPresent(String.self, forKey: .context) ?? ""
            self = .print(context)
        case .deeplink:
            let url = try container.decodeIfPresent(String.self, forKey: .url) ?? ""
            self = .deeplink(url)
        case .back:
            self = .back
        case .reload:
            self = .reload
        case .none:
            self = .none
        }
    }
}
