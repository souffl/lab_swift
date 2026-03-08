//
//  CartViewModel.swift
//  
//
//  Created by Екатерина Берендюгина on 07.03.2026.
//
import Foundation

class CartViewModel {
    private let contextService: ContextService
    private let paymentService: PaymentService
    
    init(context:ContextService, paymentService:PaymentService) {
        self.contextService = context
        self.paymentService = paymentService
    }
    
    //callbacks
    var onCartUpdated: (() -> Void)?
    var onSuccessPayment:(() -> Void)?
    var onFailPayment:((Error)->())?
    var onNeedLogin: (() -> Void)?
    
    func totalPrice() -> Decimal {return 1} //todo:change
    
    func getCart() -> [Item] { return [] }
    
    func deleteItem(item: Item) {}
    
    func increaseItemCount(item:Item) {}
    
    func decreaseItemCount(item:Item) {}
    
    func payOrder() {}
    
}
