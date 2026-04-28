import UIKit


enum DSTypography {
    static func largeTitle() -> UIFont {
        UIFont.systemFont(ofSize: 28, weight: .bold)
    }

    static func title() -> UIFont {
        UIFont.systemFont(ofSize: 22, weight: .semibold)
    }

    static func headline() -> UIFont {
        UIFont.systemFont(ofSize: 17, weight: .semibold)
    }

    static func body() -> UIFont {
        UIFont.systemFont(ofSize: 16, weight: .regular)
    }

    static func bodyMedium() -> UIFont {
        UIFont.systemFont(ofSize: 16, weight: .medium)
    }

    static func caption() -> UIFont {
        UIFont.systemFont(ofSize: 13, weight: .regular)
    }

    static func captionMedium() -> UIFont {
        UIFont.systemFont(ofSize: 13, weight: .medium)
    }

    static func button() -> UIFont {
        UIFont.systemFont(ofSize: 16, weight: .semibold)
    }

    static func fieldTitle() -> UIFont {
        UIFont.systemFont(ofSize: 13, weight: .medium)
    }
}
