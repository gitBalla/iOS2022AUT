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
                        TinderVM: TinderViewModel(), proxy: proxy,
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
    
    let ServiceType = "food-tinder"
    var peerID: MCPeerID
    var session: MCSession
    var nearbyServiceAdvertiser: MCNearbyServiceAdvertiser?
    var myResponse = "undecided"
    
    
    override init() {
        peerID = MCPeerID(displayName: UIDevice.current.name)
        session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        super.init()
        session.delegate = self
    }
    
    func advertise() {
        nearbyServiceAdvertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: ServiceType)
        nearbyServiceAdvertiser?.delegate = self
        nearbyServiceAdvertiser?.startAdvertisingPeer()
    }
    
    func join() {
        let browser = MCBrowserViewController(serviceType: ServiceType, session: session)
        browser.delegate = self
        UIApplication.shared.windows.first?.rootViewController?.present(browser , animated: true)
    }
    
    //packages the message to be sent to the connected peer. The message is that the user "DidSwipeNo"
    func didSwipeNo(at msg: String) {
        _ = "\(msg)"
        print("I am sending")
        if let msgData = msg.data(using: .utf8) {
            try? session.send(msgData, toPeers: session.connectedPeers, with: .reliable)
        }
    }
}


extension TinderViewModel: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connecting:
            print("\(peerID) state: connecting")
        case .connected:
            print("\(peerID) state: connected")
        case .notConnected:
            print("\(peerID) state: not connected")
        @unknown default:
            print("\(peerID) state: unknown")
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print("didReceive Data from \(peerID)")
        if let msg = String(data: data, encoding: .utf8){
            print("received: \(msg)")
            //theirResponse = msg
            DispatchQueue.main.async {
                //self.checkIfMatch(msg:self.theirResponse ?? "undecided",myResponse:self.myResponse ?? "undecided")
                //self.myResponse = "undecided"
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
