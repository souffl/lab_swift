//
//  ShopCatalogViewModel.swift
//  
//
//  Created by Екатерина Берендюгина on 07.03.2026.
//

import Foundation

enum ShopCatalogState: Equatable {
    case idle
    case loading
    case content([Shop])
    case empty
    case error(String)
}

@MainActor
final class ShopCatalogViewModel {
    private let shopService: ShopService
    private(set) var shops: [Shop]
    private(set) var state: ShopCatalogState = .idle

    var onShopSelected: ((Shop) -> Void)?
    var onStateChanged: ((ShopCatalogState) -> Void)?

    init(service: ShopService) {
        self.shopService = service
        self.shops = []
    }

    func loadShops() async {
        state = .loading
        onStateChanged?(state)

        do {
            let loadedShops = try await shopService.getShops()
            shops = loadedShops

            if loadedShops.isEmpty {
                state = .empty
            } else {
                state = .content(loadedShops)
            }
        } catch let error as ShopServiceError {
            state = .error(error.messageForUI)
        } catch {
            state = .error("Не удалось загрузить магазины")
        }

        onStateChanged?(state)
    }

    func selectShop(_ shop: Shop) {
        onShopSelected?(shop)
    }
}

