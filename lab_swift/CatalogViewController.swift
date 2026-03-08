//
//  CatalogViewController.swift
//  
//
//  Created by Екатерина Берендюгина on 08.03.2026.
//

import UIKit

class CatalogViewController: UIViewController
{
    let viewModel: ShopCatalogViewModel
    let router: AppRouter
    
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
        // Do any additional setup after loading the view.
    }
}
