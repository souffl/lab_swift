//
//  CatalogViewController.swift
//  
//
//  Created by Екатерина Берендюгина on 08.03.2026.
//

import UIKit

final class CatalogViewController: UIViewController {
    var viewModel: ShopCatalogViewModel
    var router: AppRouter
    
    init(viewModel: ShopCatalogViewModel, router: AppRouter) {
        self.viewModel = viewModel
        self.router = router
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.title = "Магазины"

        viewModel.onStateChanged = { state in
            print("Catalog state: \(state)")
        }

        Task {
            await viewModel.loadShops()
        }
    }
}
