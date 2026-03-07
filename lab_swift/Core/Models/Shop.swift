//
//  Shop.swift
//  lab_swift
//
//  Created by Екатерина Берендюгина on 06.03.2026.
//

struct Shop: Codable, Identifiable{
    let id: Int;
    let name: String;
    let location: String;
    
    init(id: Int, name:String, location: String) {
        self.location = location;
        self.name = name;
        self.id = id;
    }
}
