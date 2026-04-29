//
//  LocalShopLoader.swift
//  lab_swift
//
//  Created by Екатерина Берендюгина on 16.04.2026.
//

import Foundation

enum LocalShopLoaderError: Error {
    case fileNotFound
    case readFailed(Error)
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
        guard let url = Self.resolveShopsJSONURL(bundle: bundle, resourceName: resourceName) else {
            throw LocalShopLoaderError.fileNotFound
        }

        let data: Data
        do {
            data = try Data(contentsOf: url)
        } catch {
            throw LocalShopLoaderError.readFailed(error)
        }

        do {
            let decoder = JSONDecoder()
            return try decoder.decode([ShopDTO].self, from: data)
        } catch {
            throw LocalShopLoaderError.decodeFailed(error)
        }
    }

    private static func resolveShopsJSONURL(bundle: Bundle, resourceName: String) -> URL? {
        let ext = "json"
        if let url = bundle.url(forResource: resourceName, withExtension: ext) {
            return url
        }
        if let url = bundle.url(forResource: resourceName, withExtension: ext, subdirectory: "Resources") {
            return url
        }

        let bundleURL = URL(fileURLWithPath: bundle.bundlePath, isDirectory: true)
        let fileName = "\(resourceName).\(ext)"

        let nested = bundleURL.appendingPathComponent("Resources").appendingPathComponent(fileName)
        if FileManager.default.fileExists(atPath: nested.path) {
            return nested
        }

        let flat = bundleURL.appendingPathComponent(fileName)
        if FileManager.default.fileExists(atPath: flat.path) {
            return flat
        }

        guard let enumerator = FileManager.default.enumerator(
            at: bundleURL,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        ) else {
            return nil
        }

        for case let fileURL as URL in enumerator {
            if fileURL.lastPathComponent == fileName {
                return fileURL
            }
        }

        return nil
    }
}
