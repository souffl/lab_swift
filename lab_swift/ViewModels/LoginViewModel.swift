//
//  LoginViewModel.swift
//  lab_swift
//
//  Created by Екатерина Берендюгина on 07.03.2026.
//

import Foundation

final class LoginViewModel {

    private let loginService: LoginService
    private let contextService: ContextService

    var onLoginSucceeded: (() -> Void)?
    var onLoginFailed: ((String?) -> Void)?

    private(set) var isLoading = false

    init(loginService: LoginService, contextService: ContextService) {
        self.loginService = loginService
        self.contextService = contextService
    }

    func login(username: String, password: String) {
        guard !username.isEmpty, !password.isEmpty else {
            onLoginFailed?("Пустая строка")
            return
        }

        isLoading = true
        onLoginFailed?(nil)

        let result = loginService.login(username: username, password: password)
        isLoading = false

        switch result {
        case .success(let clientID):
            var context = contextService.getContext()
            context.session = .authenticated(clientID: clientID)
            _ = contextService.setContext(context: context)
            onLoginSucceeded?()

        case .invalidCredentials:
            onLoginFailed?("Неверный логин или пароль")
        case .clientNotFound:
            onLoginFailed?("Пользователь не найден")
        case .failure(let error):
            onLoginFailed?(message(for: error))
        }
    }

    private func message(for error: LoginError) -> String {
        switch error {
        case .networkUnavailable: return "Нет соединения с сетью"
        case .serverUnavailable: return "Сервер недоступен"
        case .unknown: return "Произошла ошибка"
        }
    }
}
