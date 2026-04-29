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
    /// Сеть недоступна и локальный каталог не загрузился.
    case catalogUnavailable
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
        case .catalogUnavailable:
            return "Не удалось загрузить магазины"
        case .unknown(let error):
            return error.localizedDescription
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
            return shops.compactMap { toDomainShop(shopDto:$0) }
        } catch let error as ShopServiceError {
            throw error
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

            return shopDTO.products.map { toDomainItem(shopID: shopID, itemDto:$0) }
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

            let itemDTO = shopDTO.products
                .first(where: { $0.id == String(itemID) })
            return toDomainItem(shopID: shopID, itemDto: itemDTO!)
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

            return .success(item: toDomainItem(shopID: shopID, itemDto: itemDTO))
        } catch {
            return .itemNotFound
        }
    }

    private func fetchShopDTOs() async throws -> [ShopDTO] {
        guard let url = endpoint.makeURL(configuration: configuration) else {
            throw ShopServiceError.invalidURL
        }

        do {
            return try await client.get(url)
        } catch {
            do {
                return try localLoader.loadShops()
            } catch {
                throw ShopServiceError.catalogUnavailable
            }
        }
    }
    private func toDomainShop(shopDto: ShopDTO) -> Shop? {
        Shop(
            id: shopDto.id,
            name: shopDto.name,
            location: "\(shopDto.city), \(shopDto.street)",
            imageURL: shopDto.avatarURL,
            workHours: shopDto.workHours
        )
    }
    
    private func toDomainItem(shopID: String, itemDto: ItemDTO) -> Item {
        let decimalPrice = Decimal(string: itemDto.price) ?? .zero

        return Item(
            id: itemDto.id,
            shopID: shopID,
            cost: decimalPrice,
            name: itemDto.name
        )
    }
}
