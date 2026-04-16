//
//  Item.swift
//  lab_swift
//
//  Created by Екатерина Берендюгина on 06.03.2026.
//
import Foundation

struct Item: Codable, Identifiable, Equatable {
    let id: String
    let shopID: String
    let cost: Decimal
    let name: String

    init(id: String, shopID: String, cost: Decimal, name: String) {
        self.id = id
        self.shopID = shopID
        self.cost = cost
        self.name = name
    }
    
}
