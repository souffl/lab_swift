//
//  ShopEndpoint.swift
//  lab_swift
//
//  Created by Екатерина Берендюгина on 16.04.2026.
//

import Foundation

enum ShopEndpoint {
    case shops

    func makeURL(configuration: ShopAPIConfiguration) -> URL? {
        switch self {
        case .shops:
            configuration.baseURL.appendingPathComponent("shops")
        }
    }
}
