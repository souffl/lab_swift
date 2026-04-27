//
//  Shop.swift
//  lab_swift
//
//  Created by Екатерина Берендюгина on 06.03.2026.
//

import Foundation

struct Shop: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let location: String
    let imageURL: URL?
    let workHours: String

    init(
        id: String,
        name: String,
        location: String,
        imageURL: URL? = nil,
        workHours: String = ""
    ) {
        self.id = id
        self.name = name
        self.location = location
        self.imageURL = imageURL
        self.workHours = workHours
    }
}
