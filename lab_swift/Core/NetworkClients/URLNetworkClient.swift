//
//  ShopNetworkClient.swift
//  lab_swift
//
//  Created by Екатерина Берендюгина on 16.04.2026.
//

import Foundation

enum NetworkError: Error {
    case invalidResponse
    case httpStatus(Int)
    case decoding(Error)
}

final class URLNetworkClient: NetworkClient {
    func get<T>(_ url: URL) async throws -> T where T : Decodable {
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let http = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        guard 200..<300 ~= http.statusCode else {
            throw NetworkError.httpStatus(http.statusCode)
        }
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decoding(error)
        }
    }
}
