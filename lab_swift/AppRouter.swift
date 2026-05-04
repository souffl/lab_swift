//
//  AppRoutre.swift
//  
//
//  Created by Екатерина Берендюгина on 08.03.2026.
//

protocol AppRouter {
    func showShopCatalog()
    func showShop(_ shop: Shop)
    func showBDUIScreen(config: BDUIScreenConfig)
    func showCart()
    func showLogin(completion: (() -> Void)?)
    func dismissLogin()
    func goBack()               
}
