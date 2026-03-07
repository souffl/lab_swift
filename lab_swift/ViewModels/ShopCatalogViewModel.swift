//
//  ShopCatalogViewModel.swift
//  
//
//  Created by Екатерина Берендюгина on 07.03.2026.
//

import Foundation

final class ShopCatalogViewModel {
    private let shopService: ShopService
    private(set) var shops: [Shop]
    onShopSelected: ((Shop) -> Void)?
    onLoadFailed: ((String?) -> Void)?
    
    init(service: ShopService)
    {
        self.shopService = service
        self.shops = []
    }
    
    func loadShops()
    {
        shops = shopService.getShops();
    }
    
    func selectShop(_ shop: Shop)
    
}

