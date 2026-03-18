//
//  ClientContext.swift
//  lab_swift
//
//  Created by Екатерина Берендюгина on 06.03.2026.
//
import Foundation

enum SessionState: Equatable {
    case anonymous
    case authenticated(clientID: Int)
}

struct ClientContext {
    var session: SessionState
    var cart: Array<Item>
    
    init (session: SessionState = .anonymous, cart: Array<Item> = []) {
        self.session = session
        self.cart = cart
    }
}
