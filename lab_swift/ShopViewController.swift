//
//  ShopViewController.swift
//  
//
//  Created by Екатерина Берендюгина on 08.03.2026.
//

import UIKit

class ShopViewController: UIViewController
{
    let viewModel: ShopViewModel
    let router: AppRouter
    
    init(viewModel: ShopViewModel, router: AppRouter) {
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
