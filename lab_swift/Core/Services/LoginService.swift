//
//  LoginService.swift
//  lab_swift
//
//  Created by Екатерина Берендюгина on 06.03.2026.
//

import Foundation

enum AuthResult: Equatable {
    case success(clientID: Int)
    case invalidCredentials
    case clientNotFound
    case failure(LoginError)
}
enum LoginError: Error, Equatable {
    case networkUnavailable
    case serverUnavailable
    case unknown
}

protocol LoginService {
    func login(username: String, password: String) -> AuthResult
}

