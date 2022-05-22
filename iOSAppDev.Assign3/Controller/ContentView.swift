//
//  ContentView.swift
//  iOSAppDev.Assign3
//
//  Created by Nicholas on 21/5/22.
//

import SwiftUI
import MultipeerConnectivity

//Setting up the class that will allow us to send data from the SwiftUI View to the UIKit
class ContentViewDelegate: ObservableObject {
    @Published var myResponseSwipe: String = "undecided"
}

struct ContentView: View {
    @ObservedObject var TinderVM: TinderViewModel
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
                Button("Join", action: {
                    TinderVM.join()
                }).position(x: proxy.frame(in: .local).midX + 70)
                Button("Create", action: {
                    TinderVM.advertise()
                }).position(x: proxy.frame(in: .local).midX - 70)
            }
        }
    }
}

class TinderViewModel: NSObject, ObservableObject {
    @Published private var Tinder = MCCreateViewController()
    
    let ServiceType = "tinder-food"
    
    var peerId: MCPeerID
    var session: MCSession
    var nearbyServiceAdvertiser: MCNearbyServiceAdvertiser?
    
    
    override init() {
        peerId = MCPeerID(displayName: UIDevice.current.name)
        session = MCSession(peer: peerId, securityIdentity: nil, encryptionPreference: .required)
        super.init()
        session.delegate = self
    }
    
    func advertise() {
        nearbyServiceAdvertiser = MCNearbyServiceAdvertiser(peer: peerId, discoveryInfo: nil, serviceType: ServiceType)
        nearbyServiceAdvertiser?.delegate = self
        nearbyServiceAdvertiser?.startAdvertisingPeer()
    }
    
    func join() {
        let browser = MCBrowserViewController(serviceType: ServiceType, session: session)
        browser.delegate = self
        UIApplication.shared.windows.first?.rootViewController?.present(browser , animated: true)
    }
}


extension TinderViewModel: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connecting:
            print("\(peerId) state: connecting")
        case .connected:
            print("\(peerId) state: connected")
        case .notConnected:
            print("\(peerId) state: not connected")
        @unknown default:
            print("\(peerId) state: unknown")
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let colStr = String(data: data, encoding: .utf8), let col = Int(colStr) {
            DispatchQueue.main.async {
                
            }
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
}

extension TinderViewModel: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, session)
    }
}

extension TinderViewModel: MCBrowserViewControllerDelegate {
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        browserViewController.dismiss(animated: true)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        browserViewController.dismiss(animated: true)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(TinderVM: TinderViewModel())
    }
}
