//
//  ShopAPIConfiguration.swift
//  lab_swift
//
//  Created by Екатерина Берендюгина on 16.04.2026.
//

import Foundation

struct ShopAPIConfiguration {
    let baseURL: URL

    init(baseURL: URL = URL(string: "http://localhost:3000")!) {
        self.baseURL = baseURL
    }

    static func fromBundle() -> ShopAPIConfiguration? {
        if
            let rawURL = Bundle.main.object(forInfoDictionaryKey: "SHOP_API_BASE_URL") as? String,
            let parsedURL = URL(string: rawURL),
            !rawURL.isEmpty
        {
            return ShopAPIConfiguration(baseURL: parsedURL)
        }

        return ShopAPIConfiguration()
    }
}
