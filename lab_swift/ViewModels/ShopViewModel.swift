//
//  ShopViewModel.swift
//  
//
//  Created by Екатерина Берендюгина on 07.03.2026.
//

class ShopViewModel {
    private let shopService: ShopService
    private let contextService: ContextService
    let shop: Shop
    
    var onItemSelected: ((Item) -> Void)?
    
    var onAddToCartFailed: ((String) -> Void)?
    
    init(shopService: ShopService, shop: Shop, context:ContextService) {
        self.shopService = shopService;
        self.shop = shop;
        self.contextService = context;
    }
    
    
    func getItems() -> [Item] {
        return shopService.getItems(shopID: shop.id)
    }
    
    func addItem(item:Item) {}
    
    
    
}
