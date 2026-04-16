//
//  ItemDTO.swift
//  lab_swift
//
//  Created by Екатерина Берендюгина on 16.04.2026.
//

import Foundation

struct ItemDTO: Decodable {
    let id: String
    let name: String
    let avatarURL: URL?
    let price: String
    let quantity: Int

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case avatarURL = "avatar"
        case price
        case quantity
    }
}
