//
//  Client.swift
//  
//
//  Created by Екатерина Берендюгина on 07.03.2026.
//

struct Client: Codable, Hashable, Identifiable {
    let id: String
    let login: String
    let password: String
}

