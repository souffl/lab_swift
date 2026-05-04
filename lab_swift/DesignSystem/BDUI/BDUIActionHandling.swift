import Foundation

protocol BDUIActionHandling: AnyObject {
    var onReloadRequested: (() -> Void)? { get set }
    func handle(_ action: BDUIAction)
}

final class LoggingBDUIActionHandler: BDUIActionHandling {
    var onReloadRequested: (() -> Void)?

    func handle(_ action: BDUIAction) {
        switch action {
        case .submit:
            NSLog("[BDUI] submit action triggered")
        case .print(let context):
            NSLog("[BDUI] print action: %@", context)
        case .deeplink(let url):
            NSLog("[BDUI] deeplink: %@", url)
        case .back:
            NSLog("[BDUI] back action")
        case .reload:
            NSLog("[BDUI] reload action")
            onReloadRequested?()
        case .none:
            break
        }
    }
}

final class RouterBDUIActionHandler: BDUIActionHandling {
    private let router: AppRouter
    var onReloadRequested: (() -> Void)?

    init(router: AppRouter) {
        self.router = router
    }

    func handle(_ action: BDUIAction) {
        switch action {
        case .submit:
            NSLog("[BDUI] submit action triggered")
        case .print(let context):
            NSLog("[BDUI] print action: %@", context)
        case .deeplink(let raw):
            handleDeeplink(raw)
        case .back:
            router.goBack()
        case .reload:
            onReloadRequested?()
        case .none:
            break
        }
    }

    private func handleDeeplink(_ raw: String) {
        guard let url = URL(string: raw), let host = url.host else {
            NSLog("[BDUI] invalid deeplink: %@", raw)
            return
        }

        switch host {
        case "catalog", "shops":
            router.showShopCatalog()
        case "cart":
            router.showCart()
        case "login":
            router.showLogin(completion: nil)
        case "back":
            router.goBack()
        default:
            NSLog("[BDUI] unknown deeplink host: %@", host)
        }
    }
}
