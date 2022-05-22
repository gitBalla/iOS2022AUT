//
//  User.swift
//  iOSAppDev.Assign3
//
//  Created by Nicholas on 22/5/22.
//

import Foundation

struct User: Identifiable {
    let id: UUID = .init()
    let name: String
    let distance: String
    let image: String
    var isBehind: Bool = true
    
    static let users = [
        User(name: "Pizza", distance: "10", image: "Pizza"),
        User(name: "Salmon", distance: "20", image: "Salmon"),
        User(name: "Indian", distance: "15", image: "Indian"),
        User(name: "Pizza", distance: "10", image: "Pizza", isBehind: false),
    ]
}
