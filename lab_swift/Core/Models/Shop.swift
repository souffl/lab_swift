//
//  Shop.swift
//  lab_swift
//
//  Created by Екатерина Берендюгина on 06.03.2026.
//

struct Shop: Codable, Identifiable, Equatable {
    let id: String;
    let name: String;
    let location: String;
    
    init(id: String, name:String, location: String) {
        self.location = location
        self.name = name
        self.id = id
    }
}
