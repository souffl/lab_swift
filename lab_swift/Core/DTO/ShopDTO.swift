//
//  ShopDTO.swift
//  lab_swift
//
//  Created by Екатерина Берендюгина on 16.04.2026.
//
import Foundation

struct ShopDTO: Decodable {
    let id: String
    let name: String
    let avatarURL: URL?
    let city: String
    let street: String
    let rating: Double
    let workHours: String
    let phone: String
    let products: [ItemDTO]

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case avatarURL = "avatar_url"
        case city
        case street
        case rating
        case workHours = "work_hours"
        case phone
        case products
    }

   
}
