import CoreGraphics
import Foundation

struct BDUISize: Decodable {
    let width: CGFloat?
    let height: CGFloat?
}

struct BDUIInsets: Decodable {
    let top: CGFloat?
    let leading: CGFloat?
    let bottom: CGFloat?
    let trailing: CGFloat?

    init(from decoder: Decoder) throws {
        if let single = try? decoder.singleValueContainer(), let value = try? single.decode(CGFloat.self) {
            self.top = value
            self.leading = value
            self.bottom = value
            self.trailing = value
            return
        }

        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.top = try container.decodeIfPresent(CGFloat.self, forKey: .top)
        self.leading = try container.decodeIfPresent(CGFloat.self, forKey: .leading)
        self.bottom = try container.decodeIfPresent(CGFloat.self, forKey: .bottom)
        self.trailing = try container.decodeIfPresent(CGFloat.self, forKey: .trailing)
    }

    enum CodingKeys: String, CodingKey {
        case top
        case leading
        case bottom
        case trailing
    }
}

struct BDUIStyle: Decodable {
    let backgroundColor: BDUIColor?
    let cornerRadius: CGFloat?
    let shadow: CGFloat?
    let size: BDUISize?
    let padding: BDUIInsets?
    let borderColor: BDUIColor?
    let borderWidth: CGFloat?
}

struct BDUIText: Decodable {
    let value: String
    let typography: BDUITypography?
    let color: BDUIColor?
    let alignment: String?
    let numberOfLines: Int?

    init(from decoder: Decoder) throws {
        if let single = try? decoder.singleValueContainer(), let string = try? single.decode(String.self) {
            self.value = string
            self.typography = nil
            self.color = nil
            self.alignment = nil
            self.numberOfLines = nil
            return
        }

        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.value = try container.decode(String.self, forKey: .value)
        self.typography = try container.decodeIfPresent(BDUITypography.self, forKey: .typography)
        self.color = try container.decodeIfPresent(BDUIColor.self, forKey: .color)
        self.alignment = try container.decodeIfPresent(String.self, forKey: .alignment)
        self.numberOfLines = try container.decodeIfPresent(Int.self, forKey: .numberOfLines)
    }

    enum CodingKeys: String, CodingKey {
        case value
        case typography
        case color
        case alignment
        case numberOfLines
    }
}

struct BDUIStackView: Decodable {
    let views: [BDUIView]
    let innerSpace: CGFloat?
    let direction: BDUIDirection?
    let alignment: BDUIAlignment?
    let distribution: BDUIDistribution?
    let style: BDUIStyle?
}

struct BDUILabelView: Decodable {
    let text: BDUIText
    let style: BDUIStyle?
}

struct BDUIIconView: Decodable {
    let imageUrl: String
    let size: CGFloat?
    let style: BDUIStyle?
    let tint: BDUIColor?
}

struct BDUIButtonView: Decodable {
    let text: BDUIText
    let action: BDUIAction
    let style: BDUIStyle?
    let buttonStyle: BDUIButtonStyle?
}

struct BDUISpacerView: Decodable {
    let size: CGFloat?
    let width: CGFloat?
    let height: CGFloat?
}

struct BDUITextFieldView: Decodable {
    let title: String?
    let placeholder: String?
    let text: String?
    let isSecure: Bool?
    let isEnabled: Bool?
    let returnKeyType: String?
    let style: BDUIStyle?
}

struct BDUIListView: Decodable {
    let direction: BDUIDirection?
    let innerSpace: CGFloat?
    let alignment: BDUIAlignment?
    let distribution: BDUIDistribution?
    let style: BDUIStyle?
    let items: [BDUIJSONValue]
    let template: BDUIJSONValue
}

struct BDUILoadingView: Decodable {
    let message: String?
    let style: BDUIStyle?
}

struct BDUIEmptyView: Decodable {
    let title: String
    let message: String?
    let iconSystemName: String?
    let style: BDUIStyle?
}

struct BDUIErrorView: Decodable {
    let message: String
    let buttonTitle: String?
    let iconSystemName: String?
    let action: BDUIAction?
    let style: BDUIStyle?
}

enum BDUIView: Decodable {
    case stack(BDUIStackView)
    case label(BDUILabelView)
    case icon(BDUIIconView)
    case button(BDUIButtonView)
    case spacer(BDUISpacerView)
    case textField(BDUITextFieldView)
    case list(BDUIListView)
    case loadingView(BDUILoadingView)
    case emptyView(BDUIEmptyView)
    case errorView(BDUIErrorView)

    private enum DiscriminatorKey: String, CodingKey {
        case type
    }

    private enum Kind: String, Decodable {
        case stack
        case label
        case icon
        case button
        case spacer
        case textField
        case list
        case loadingView
        case emptyView
        case errorView
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DiscriminatorKey.self)
        let kind = try container.decode(Kind.self, forKey: .type)
        switch kind {
        case .stack:
            self = .stack(try BDUIStackView(from: decoder))
        case .label:
            self = .label(try BDUILabelView(from: decoder))
        case .icon:
            self = .icon(try BDUIIconView(from: decoder))
        case .button:
            self = .button(try BDUIButtonView(from: decoder))
        case .spacer:
            self = .spacer(try BDUISpacerView(from: decoder))
        case .textField:
            self = .textField(try BDUITextFieldView(from: decoder))
        case .list:
            self = .list(try BDUIListView(from: decoder))
        case .loadingView:
            self = .loadingView(try BDUILoadingView(from: decoder))
        case .emptyView:
            self = .emptyView(try BDUIEmptyView(from: decoder))
        case .errorView:
            self = .errorView(try BDUIErrorView(from: decoder))
        }
    }
}
