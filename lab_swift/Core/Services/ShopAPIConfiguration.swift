//
//  ShopAPIConfiguration.swift
//  lab_swift
//
//  Created by Екатерина Берендюгина on 16.04.2026.
//

import Foundation

struct ShopAPIConfiguration {
    let baseURL: URL

    init(baseURL: URL = URL(string: "https://69e00f1a29c070e6597b15f3.mockapi.io/floristshop")!) {
        self.baseURL = baseURL
    }

    static func fromBundle() -> ShopAPIConfiguration? {
        ShopAPIConfiguration()
    }
}
