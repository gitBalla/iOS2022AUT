//
//  User.swift
//  iOSAppDev.Assign3
//
//  Created by Nicholas on 22/5/22.
//
// this File holds all data on the Restaurant cards 

import Foundation

struct Restaurant: Identifiable {
    let id: UUID = .init()
    let name: String
    let distance: String
    let image: String
    var isBehind: Bool = true
    
    static let restaurants = [
        Restaurant(name: "Pizza", distance: "10", image: "Pizza"),
        Restaurant(name: "Salmon", distance: "20", image: "Salmon"),
        Restaurant(name: "Indian", distance: "15", image: "Indian"),
        Restaurant(name: "Pizza", distance: "10", image: "Pizza", isBehind: false),
    ]
}
