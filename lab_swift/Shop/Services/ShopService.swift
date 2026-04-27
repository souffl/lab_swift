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
    func getShops() async throws -> [Shop]
    func getItems(shopID: String) async -> [Item]
    func findItem(shopID: String, by itemID: Int) async -> Item?
    func hasItem(shopID: String, itemID: Int) async -> Bool
    func issueItem(shopID: String, itemID: Int, quantity: Int) async -> IssueResult
    
}
