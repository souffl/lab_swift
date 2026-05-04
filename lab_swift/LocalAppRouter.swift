import UIKit

final class LocalAppRouter: AppRouter {
    private weak var navigationController: UINavigationController?
    
    private let contextService: ContextService
    private let loginService: LoginService
    private let bduiScreenLoader: BDUIScreenLoading
    private let bduiPathBuilder: ShopBDUIScreenPathBuilding
    
    init(
        navigationController: UINavigationController,
        contextService: ContextService,
        loginService: LoginService,
        bduiScreenLoader: BDUIScreenLoading = HTTPBDUIScreenLoader(),
        bduiPathBuilder: ShopBDUIScreenPathBuilding = EchoShopBDUIScreenPathBuilder.fromBundle()
    ) {
        self.navigationController = navigationController
        self.contextService = contextService
        self.loginService = loginService
        self.bduiScreenLoader = bduiScreenLoader
        self.bduiPathBuilder = bduiPathBuilder
    }
    
    func showShopCatalog() {
        let configuration = ShopAPIConfiguration.fromBundle() ?? ShopAPIConfiguration()
        let client = URLNetworkClient()
        let service = NetworkShopService(
            client: client,
            configuration: configuration
        )
        let viewModel = ShopCatalogViewModel(service: service)
        let vc = CatalogViewController(viewModel: viewModel, router: self)
        navigationController?.setViewControllers([vc], animated: true)
    }
    
    func showShop(_ shop: Shop) {
        let config = bduiPathBuilder.makeConfig(for: shop)
        let components = makeBDUIComponents(config: config)
        let vc = ShopDetailsViewController(shop: shop) {
            BDUIScreenView(
                viewModel: components.viewModel,
                mapper: components.mapper,
                actionHandler: components.actionHandler
            )
        }
        navigationController?.pushViewController(vc, animated: true)
    }

    func showBDUIScreen(config: BDUIScreenConfig) {
        let vc = makeBDUIScreen(config: config)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func showCart() {
        let vc = PlaceholderViewController(text: "Cart (заглушка)")
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func showLogin(completion: (() -> Void)?) {
        let vm = LoginViewModel(loginService: loginService, contextService: contextService)
        let vc = LoginViewController(viewModel: vm, router: self, onLoginSucceeded: completion)
        navigationController?.setViewControllers([vc], animated: true)
    }
    
    func dismissLogin() {
        navigationController?.popViewController(animated: true)
    }

    func goBack() {
        navigationController?.popViewController(animated: true)
    }

    private func makeBDUIScreen(config: BDUIScreenConfig) -> BDUIViewController {
        let components = makeBDUIComponents(config: config)
        return BDUIViewController(
            title: config.title,
            viewModel: components.viewModel,
            mapper: components.mapper,
            actionHandler: components.actionHandler
        )
    }

    private func makeBDUIComponents(config: BDUIScreenConfig) -> BDUIComponents {
        let viewModel = BDUIScreenViewModel(loader: bduiScreenLoader, config: config)
        let actionHandler = RouterBDUIActionHandler(router: self)
        let mapper = BDUIViewMapper(actionHandler: actionHandler)
        return BDUIComponents(viewModel: viewModel, mapper: mapper, actionHandler: actionHandler)
    }
}

private struct BDUIComponents {
    let viewModel: BDUIScreenViewModel
    let mapper: BDUIViewMapping
    let actionHandler: BDUIActionHandling
}

protocol ShopBDUIScreenPathBuilding {
    func makeConfig(for shop: Shop) -> BDUIScreenConfig
}

struct EchoShopBDUIScreenPathBuilder: ShopBDUIScreenPathBuilding {
    private let pathPrefix: String
    private let productsNode: String

    init(pathPrefix: String = "shops", productsNode: String = "products") {
        self.pathPrefix = pathPrefix
        self.productsNode = productsNode
    }

    static func fromBundle() -> EchoShopBDUIScreenPathBuilder {
        let rawPrefix = Bundle.main.object(forInfoDictionaryKey: "BDUI_SHOP_PATH_PREFIX") as? String
        let rawProductsNode = Bundle.main.object(forInfoDictionaryKey: "BDUI_SHOP_PRODUCTS_PATH_NODE") as? String

        let normalizedPrefix: String
        if let rawPrefix {
            let trimmed = rawPrefix.trimmingCharacters(in: .whitespacesAndNewlines)
            normalizedPrefix = trimmed.isEmpty ? "shops" : trimmed
        } else {
            normalizedPrefix = "shops"
        }

        let normalizedProductsNode: String
        if let rawProductsNode {
            let trimmed = rawProductsNode.trimmingCharacters(in: .whitespacesAndNewlines)
            normalizedProductsNode = trimmed.isEmpty ? "products" : trimmed
        } else {
            normalizedProductsNode = "products"
        }

        return EchoShopBDUIScreenPathBuilder(pathPrefix: normalizedPrefix, productsNode: normalizedProductsNode)
    }

    func makeConfig(for shop: Shop) -> BDUIScreenConfig {
        BDUIScreenConfig(
            title: "Товары магазина",
            endpointPath: "\(pathPrefix)/\(shop.id)/\(productsNode)"
        )
    }
}

private final class PlaceholderViewController: UIViewController {
    private let text: String
    
    init(text: String) {
        self.text = text
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = DS.palette.background
        navigationItem.title = "Экран"
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.textAlignment = .center
        label.numberOfLines = 0
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

