//
//  App.swift
//  iOSAppDev.Assign3
//
//  Created by Shahriar Karim on 22/5/2022.
//

import Foundation
import SwiftUI

//@main
struct TinderApp: App {
    var body: some Scene {
        WindowGroup {
            let tinderVM = TinderViewModel()
            ContentView(TinderVM: tinderVM)
        }
    }
}
