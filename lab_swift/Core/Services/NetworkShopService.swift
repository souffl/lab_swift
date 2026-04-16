//
//  NetworkShopService.swift
//  lab_swift
//
//  Created by Екатерина Берендюгина on 16.04.2026.
//

import Foundation

enum ShopServiceError: Error {
    case invalidURL
    case network(NetworkError)
    case unknown(Error)

    var messageForUI: String {
        switch self {
        case .invalidURL:
            return "Некорректный URL запроса"
        case .network(let error):
            switch error {
            case .invalidResponse:
                return "Сервер вернул некорректный ответ"
            case .httpStatus(let code):
                return "Ошибка сервера: \(code)"
            case .decoding:
                return "Не удалось разобрать данные"
            }
        case .unknown:
            return "Неизвестная ошибка"
        }
    }
}

final class NetworkShopService: ShopService {
    private let client: NetworkClient
    private let configuration: ShopAPIConfiguration
    private let endpoint: ShopEndpoint
    private let localLoader: LocalShopLoader

    init(
        client: NetworkClient,
        configuration: ShopAPIConfiguration,
        endpoint: ShopEndpoint = .shops,
        localLoader: LocalShopLoader = LocalShopLoader()
    ) {
        self.client = client
        self.configuration = configuration
        self.endpoint = endpoint
        self.localLoader = localLoader
    }

    func getShops() async throws -> [Shop] {
        do {
            let shops = try await fetchShopDTOs()
            return shops.compactMap { $0.toDomainShop() }
        } catch let error as NetworkError {
            throw ShopServiceError.network(error)
        } catch {
            throw ShopServiceError.unknown(error)
        }
    }

    func getItems(shopID: String) async -> [Item] {
        do {
            let shops = try await fetchShopDTOs()

            guard let shopDTO = shops.first(where: { $0.id == shopID }) else {
                return []
            }

            return shopDTO.products.map { $0.toDomainItem(shopID: shopID) }
        } catch {
            return []
        }
    }

    func findItem(shopID: String, by itemID: Int) async -> Item? {
        do {
            let shops = try await fetchShopDTOs()

            guard let shopDTO = shops.first(where: { $0.id == shopID }) else {
                return nil
            }

            return shopDTO.products
                .first(where: { $0.id == String(itemID) })?
                .toDomainItem(shopID: shopID)
        } catch {
            return nil
        }
    }

    func hasItem(shopID: String, itemID: Int) async -> Bool {
        await findItem(shopID: shopID, by: itemID) != nil
    }

    func issueItem(shopID: String, itemID: Int, quantity: Int) async -> IssueResult {
        guard quantity > 0 else {
            return .itemNotFound
        }

        do {
            let shops = try await fetchShopDTOs()

            guard let shopDTO = shops.first(where: { $0.id == shopID }) else {
                return .itemNotFound
            }

            guard let itemDTO = shopDTO.products.first(where: { $0.id == String(itemID) }) else {
                return .itemNotFound
            }

            guard itemDTO.quantity >= quantity else {
                return .outOfStock
            }

            return .success(item: itemDTO.toDomainItem(shopID: shopID))
        } catch {
            return .itemNotFound
        }
    }

    private func fetchShopDTOs() async throws -> [ShopDTO] {
        guard let url = endpoint.makeURL(configuration: configuration) else {
            throw ShopServiceError.invalidURL
        }

        let shops: [ShopDTO]

        do {
            shops = try await client.get(url)
        } catch {
            shops = try localLoader.loadShops()
        }
        return shops
    }
}
