//
//  LocalShopLoader.swift
//  lab_swift
//
//  Created by Екатерина Берендюгина on 16.04.2026.
//

import Foundation

enum LocalShopLoaderError: Error {
    case fileNotFound
    case decodeFailed(Error)
}

final class LocalShopLoader {
    private let bundle: Bundle
    private let resourceName: String

    init(bundle: Bundle = .main, resourceName: String = "shops") {
        self.bundle = bundle
        self.resourceName = resourceName
    }

    func loadShops() throws -> [ShopDTO] {
        guard let url = bundle.url(forResource: resourceName, withExtension: "json") else {
            throw LocalShopLoaderError.fileNotFound
        }

        let data = try Data(contentsOf: url)

        do {
            let decoder = JSONDecoder()
            return try decoder.decode([ShopDTO].self, from: data)
        } catch {
            throw LocalShopLoaderError.decodeFailed(error)
        }
    }
}
