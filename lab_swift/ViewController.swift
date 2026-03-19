import UIKit

final class ViewController: UIViewController {
    private var rootNavigationController: UINavigationController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        rootNavigationController = UINavigationController()
        rootNavigationController.navigationBar.prefersLargeTitles = false
        
        addChild(rootNavigationController)
        view.addSubview(rootNavigationController.view)
        rootNavigationController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            rootNavigationController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            rootNavigationController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            rootNavigationController.view.topAnchor.constraint(equalTo: view.topAnchor),
            rootNavigationController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        rootNavigationController.didMove(toParent: self)
        
        let contextService = LocalContextService()
        let loginService = LocalLoginService()
        let router = LocalAppRouter(
            navigationController: rootNavigationController,
            contextService: contextService,
            loginService: loginService
        )
        
        let context = contextService.getContext()
        switch context.session {
        case .anonymous:
            router.showLogin(completion: nil)
        case .authenticated:
            router.showShopCatalog()
        }
    }
}

