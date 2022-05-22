//
//  ContentView.swift
//  iOSAppDev.Assign3
//
//  Created by Nicholas on 21/5/22.
//

import SwiftUI

struct ContentView: View {
    @State var restaurants = Restaurant.restaurants
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                ForEach(Array(restaurants.enumerated()), id: \.offset) { index, user in
                    CardView(
                        proxy: proxy,
                        restaurant: user,
                        index: index
                    ) { (index) in
                        restaurants.remove(at: index)
                        if index > 0 {
                            restaurants[index - 1].isBehind = false
                        }
                    }
                }
                Button("reload", action: {
                    restaurants.append(contentsOf: Restaurant.restaurants)
                }).position(x: proxy.frame(in: .local).midX)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
