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
    private var cachedShops: [ShopDTO] = []

    init(
        client: NetworkClient,
        configuration: ShopAPIConfiguration,
        endpoint: ShopEndpoint = .shops
    ) {
        self.client = client
        self.configuration = configuration
        self.endpoint = endpoint
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

    func findItem(shopID: String, by itemID: Int) -> Item? {
        let itemIDString = String(itemID)

        return cachedShops
            .first(where: { $0.id == shopID })?
            .products
            .first(where: { $0.id == itemIDString })?
            .toDomainItem(shopID: shopID)
    }

    func hasItem(shopID: String, itemID: Int) -> Bool {
        findItem(shopID: shopID, by: itemID) != nil
    }

    func issueItem(shopID: String, itemID: Int, quantity: Int) -> IssueResult {
        guard quantity > 0 else {
            return .itemNotFound
        }

        guard let item = findItem(shopID: shopID, by: itemID) else {
            return .itemNotFound
        }

        guard
            let shopDTO = cachedShops.first(where: { $0.id == shopID }),
            let itemDTO = shopDTO.products.first(where: { $0.id == String(itemID) })
        else {
            return .itemNotFound
        }

        return itemDTO.quantity >= quantity ? .success(item: item) : .outOfStock
    }

    private func fetchShopDTOs() async throws -> [ShopDTO] {
        guard let url = endpoint.makeURL(configuration: configuration) else {
            throw ShopServiceError.invalidURL
        }

        let shops: [ShopDTO] = try await client.get(url)
        cachedShops = shops
        return shops
    }
}
