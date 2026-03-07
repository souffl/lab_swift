//
//  ShopService.swift
//  lab_swift
//
//  Created by Екатерина Берендюгина on 06.03.2026.
//
enum IssueResult: Equatable {
    case success(item: Item)
    case outOfStock
    case itemNotFound
}

protocol ShopService {
    func getShops() -> [Shop]
    func getItems(shopID: Int) -> [Item]
    func findItem(shopID: Int, by itemID: Int) -> Item?
    func hasItem(shopID: Int, itemID: Int) -> Bool
    func issueItem(shopID: Int,itemID: Int, quantity: Int) -> IssueResult
    
}
