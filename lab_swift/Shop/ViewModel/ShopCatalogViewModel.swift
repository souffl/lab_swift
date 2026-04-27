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
    case content([ShopCellViewModel])
    case empty
    case error(String)
}

@MainActor
final class ShopCatalogViewModel {
    private let shopService: ShopService
    private(set) var shops: [Shop]
    private(set) var filteredShops: [Shop]
    private(set) var state: ShopCatalogState = .idle
    private(set) var searchQuery: String = ""

    var onShopSelected: ((Shop) -> Void)?
    var onStateChanged: ((ShopCatalogState) -> Void)?

    init(service: ShopService) {
        self.shopService = service
        self.shops = []
        self.filteredShops = []
    }

    func loadShops() async {
        state = .loading
        onStateChanged?(state)

        do {
            let loadedShops = try await shopService.getShops()
            shops = loadedShops
            updateContentState()
        } catch let error as ShopServiceError {
            state = .error(error.messageForUI)
        } catch {
            state = .error("Не удалось загрузить магазины")
        }

        onStateChanged?(state)
    }

    func retryLoading() async {
        await loadShops()
    }

    func updateSearchQuery(_ query: String) {
        searchQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        updateContentState()
        onStateChanged?(state)
    }

    func selectShop(id: String) {
        guard let shop = filteredShops.first(where: { $0.id == id }) else {
            return
        }

        onShopSelected?(shop)
    }

    private func updateContentState() {
        filteredShops = applyFilter(query: searchQuery, to: shops)

        if filteredShops.isEmpty {
            state = .empty
        } else {
            state = .content(ShopCellViewModelMapper.map(filteredShops))
        }
    }

    private func applyFilter(query: String, to shops: [Shop]) -> [Shop] {
        guard !query.isEmpty else {
            return shops
        }

        let normalizedQuery = query.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
        return shops.filter { shop in
            let normalizedName = shop.name.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
            return normalizedName.contains(normalizedQuery)
        }
    }
}

