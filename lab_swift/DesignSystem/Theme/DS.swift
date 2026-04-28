import UIKit

//mark: notification
extension Notification.Name {
    static let dsThemeDidChange = Notification.Name("DesignSystem.themeDidChange")
}

enum DSThemeKind: String, CaseIterable, Sendable {

    case warm

    case dark

    var userInterfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .warm:
            .light
        case .dark:
            .dark
        }
    }
}

enum DS {
    private static let themeStorageKey = "DesignSystem.themeKind"

    private(set) static var themeKind: DSThemeKind = DS.loadStoredThemeKind() ?? .warm {
        didSet {
            UserDefaults.standard.set(themeKind.rawValue, forKey: themeStorageKey)
        }
    }

    static var palette: DSPalette {
        switch themeKind {
        case .warm:
            DSPalette.warm()
        case .dark:
            DSPalette.dark()
        }
    }


    static func applyTheme(_ kind: DSThemeKind, window: UIWindow? = nil) {
        themeKind = kind
        window?.overrideUserInterfaceStyle = kind.userInterfaceStyle
        //todo: remove this 
        NotificationCenter.default.post(name: .dsThemeDidChange, object: nil)
    }

   
    static func applyThemeToWindows(in scene: UIScene?) {
        guard let windowScene = scene as? UIWindowScene else {
            return
        }

        for window in windowScene.windows {
            window.overrideUserInterfaceStyle = themeKind.userInterfaceStyle
        }
    }

    private static func loadStoredThemeKind() -> DSThemeKind? {
        guard let raw = UserDefaults.standard.string(forKey: themeStorageKey) else {
            return nil
        }

        return DSThemeKind(rawValue: raw)
    }
}
