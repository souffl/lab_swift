//
//  NetworkClient.swift
//  lab_swift
//
//  Created by Екатерина Берендюгина on 16.04.2026.
//
import Foundation

protocol NetworkClient {
    func get<T: Decodable>(_ url: URL) async throws -> T
}
