//
//  ContentView.swift
//  iOSAppDev.Assign3
//
//  Created by Nicholas on 21/5/22.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                CardView(proxy: proxy)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
