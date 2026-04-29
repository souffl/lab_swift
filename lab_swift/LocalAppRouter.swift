import UIKit

final class LocalAppRouter: AppRouter {
    private weak var navigationController: UINavigationController?
    
    private let contextService: ContextService
    private let loginService: LoginService
    
    init(
        navigationController: UINavigationController,
        contextService: ContextService,
        loginService: LoginService
    ) {
        self.navigationController = navigationController
        self.contextService = contextService
        self.loginService = loginService
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
        let vc = ShopDetailsViewController(shop: shop)
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

