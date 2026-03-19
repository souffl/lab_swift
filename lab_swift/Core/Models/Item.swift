//
//  Item.swift
//  lab_swift
//
//  Created by Екатерина Берендюгина on 06.03.2026.
//
import Foundation

struct Item: Codable, Identifiable, Equatable {
    let id: Int
    let shopID: Int
    let cost: Decimal
    let name: String

    init(id: Int, shop_id: Int, cost: Decimal, name: String) {
        self.id = id
        self.shopID = shop_id
        self.cost = cost
        self.name = name
    }
    
}
