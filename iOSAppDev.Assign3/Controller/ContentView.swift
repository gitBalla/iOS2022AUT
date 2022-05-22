//
//  ContentView.swift
//  iOSAppDev.Assign3
//
//  Created by Nicholas on 21/5/22.
//

import SwiftUI

struct ContentView: View {
    @State var users = User.users
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                ForEach(Array(users.enumerated()), id: \.offset) { index, user in
                    CardView(
                        proxy: proxy,
                        user: user,
                        index: index
                    ) { (index) in
                        users.remove(at: index)
                        if index > 0 {
                            users[index - 1].isBehind = false
                        }
                    }
                }
                Button("reload", action: {
                    users.append(contentsOf: User.users)
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
