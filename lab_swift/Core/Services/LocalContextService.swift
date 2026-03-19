import Foundation

enum LocalContextError: Error {
    case failedToSave
}

final class LocalContextService: ContextService {
    private enum Keys {
        static let sessionType = "lab_swift.session_type"
        static let clientID = "lab_swift.client_id"
        static let cartData = "lab_swift.cart_data"
    }
    
    private enum SessionType: String {
        case anonymous
        case authenticated
    }
    
    
    
    private let userDefaults: UserDefaults
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    func setContext(context: ClientContext) -> Bool {
        do {
            switch context.session {
            case .anonymous:
                userDefaults.set(SessionType.anonymous.rawValue, forKey: Keys.sessionType)
                userDefaults.removeObject(forKey: Keys.clientID)
                
            case .authenticated(let clientID):
                userDefaults.set(SessionType.authenticated.rawValue, forKey: Keys.sessionType)
                userDefaults.set(clientID, forKey: Keys.clientID)
            }
            
            let cartEncoded = try JSONEncoder().encode(context.cart)
            userDefaults.set(cartEncoded, forKey: Keys.cartData)
            return true
        } catch {
            return false
        }
    }
    
    func getContext() -> ClientContext {
        let sessionTypeRaw = userDefaults.string(forKey: Keys.sessionType)
        let sessionType = SessionType(rawValue: sessionTypeRaw ?? "") ?? .anonymous
        
        let session: SessionState
        switch sessionType {
        case .anonymous:
            session = .anonymous
        case .authenticated:
            let clientID = userDefaults.integer(forKey: Keys.clientID)
            session = .authenticated(clientID: clientID)
        }
        
        let cart: [Item]
        if
            let cartData = userDefaults.data(forKey: Keys.cartData),
            let decoded = try? JSONDecoder().decode([Item].self, from: cartData)
        {
            cart = decoded
        } else {
            cart = []
        }
        
        return ClientContext(session: session, cart: cart)
    }
    
    func getCart() -> [Item] {
        getContext().cart
    }
    
    func addItem(item: Item) -> Result<Void, Error> {
        var context = getContext()
        
        if let existingIndex = context.cart.firstIndex(where: { $0.id == item.id }) {
            context.cart[existingIndex] = item
        } else {
            context.cart.append(item)
        }
        
        guard setContext(context: context) else {
            return .failure(LocalContextError.failedToSave)
        }
        return .success(())
    }
    
    func deleteItem(item: Item) -> Result<Void, Error> {
        var context = getContext()
        context.cart.removeAll(where: { $0.id == item.id })
        
        guard setContext(context: context) else {
            return .failure(LocalContextError.failedToSave)
        }
        return .success(())
    }
}

