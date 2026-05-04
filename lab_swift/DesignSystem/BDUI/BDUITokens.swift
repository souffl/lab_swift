import UIKit

enum BDUIDirection: String, Decodable {
    case column
    case row

    var axis: NSLayoutConstraint.Axis {
        switch self {
        case .column:
            return .vertical
        case .row:
            return .horizontal
        }
    }
}

enum BDUIAlignment: String, Decodable {
    case fill
    case leading
    case center
    case trailing

    var stackAlignment: UIStackView.Alignment {
        switch self {
        case .fill:
            return .fill
        case .leading:
            return .leading
        case .center:
            return .center
        case .trailing:
            return .trailing
        }
    }
}

enum BDUIDistribution: String, Decodable {
    case fill
    case fillEqually
    case fillProportionally
    case equalSpacing

    var stackDistribution: UIStackView.Distribution {
        switch self {
        case .fill:
            return .fill
        case .fillEqually:
            return .fillEqually
        case .fillProportionally:
            return .fillProportionally
        case .equalSpacing:
            return .equalSpacing
        }
    }
}

enum BDUIColor: String, Decodable {
    case background
    case surface
    case primary
    case onPrimary
    case secondary
    case textPrimary
    case textSecondary
    case error
    case errorText
    case border
    case separator
    case statusPositive
    case statusNegative
    case iconMuted

    case white
    case black
    case clear
    case gray
    case blue

    var uiColor: UIColor {
        switch self {
        case .background:
            return DS.palette.background
        case .surface:
            return DS.palette.surface
        case .primary:
            return DS.palette.primary
        case .onPrimary:
            return DS.palette.onPrimary
        case .secondary:
            return DS.palette.secondary
        case .textPrimary:
            return DS.palette.textPrimary
        case .textSecondary:
            return DS.palette.textSecondary
        case .error:
            return DS.palette.error
        case .errorText:
            return DS.palette.errorText
        case .border:
            return DS.palette.border
        case .separator:
            return DS.palette.separator
        case .statusPositive:
            return DS.palette.statusPositive
        case .statusNegative:
            return DS.palette.statusNegative
        case .iconMuted:
            return DS.palette.iconMuted
        case .white:
            return .white
        case .black:
            return .black
        case .clear:
            return .clear
        case .gray:
            return .systemGray
        case .blue:
            return .systemBlue
        }
    }
}

enum BDUITypography: String, Decodable {
    case largeTitle
    case title
    case headline
    case body
    case bodyMedium
    case caption
    case captionMedium
    case button
    case fieldTitle

    var font: UIFont {
        switch self {
        case .largeTitle:
            return DSTypography.largeTitle()
        case .title:
            return DSTypography.title()
        case .headline:
            return DSTypography.headline()
        case .body:
            return DSTypography.body()
        case .bodyMedium:
            return DSTypography.bodyMedium()
        case .caption:
            return DSTypography.caption()
        case .captionMedium:
            return DSTypography.captionMedium()
        case .button:
            return DSTypography.button()
        case .fieldTitle:
            return DSTypography.fieldTitle()
        }
    }
}

enum BDUIButtonStyle: String, Decodable {
    case primary
    case secondary

    var dsStyle: DSButton.Style {
        switch self {
        case .primary:
            return .primary
        case .secondary:
            return .secondary
        }
    }
}
