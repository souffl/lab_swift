import Foundation

final class LocalLoginService: LoginService {
    private enum Constants {
        static let correctLogin = "admin"
        static let correctPassword = "1234"
        static let correctClientID = 1
    }
    
    func login(username: String, password: String) -> AuthResult {
        guard username == Constants.correctLogin,
              password == Constants.correctPassword
        else {
            return .invalidCredentials
        }
        
        return .success(clientID: Constants.correctClientID)
    }
}

