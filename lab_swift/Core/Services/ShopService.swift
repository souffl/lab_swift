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
    func getShopName() -> String
    func getItems() -> [Item]
    func findItem(by itemID: Int) -> Item?
    func hasItem(itemID: Int) -> Bool
    func issueItem(itemID: Int, quantity: Int) -> IssueResult
    
}
