//
//  TinderFoodViewController.swift
//  iOSAppDev.Assign3
//
//  Created by Nicholas on 21/5/22.
//

import UIKit
import SwiftUI

class TinderFoodViewController: UIViewController {
    
    let contentView = UIHostingController(rootView: ContentView())
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                CardView(proxy: proxy, user: User.users[0], index: 0, onRemove: nil)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addChild(contentView)
        view.addSubview(contentView.view)
        setupConstraints()
    }
    
    //sets up the constraints for the SwiftUI host controller
    fileprivate func setupConstraints() {
    contentView.view.translatesAutoresizingMaskIntoConstraints = false
    contentView.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
    contentView.view.bottomAnchor.constraint(equalTo:view.bottomAnchor).isActive = true
    contentView.view.leftAnchor.constraint(equalTo:view.leftAnchor).isActive = true
    contentView.view.rightAnchor.constraint(equalTo:view.rightAnchor).isActive = true
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
