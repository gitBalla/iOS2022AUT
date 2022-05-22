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
    var myResponse:String? = "undecided"
    var theirResponse:String? = "undecided"
    var isMatch:Bool = false
    
    
    //initialise base variables for MultipeerConnectivity
    override init() {
        peerID = MCPeerID(displayName: UIDevice.current.name)
        session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        super.init()
        session.delegate = self
    }
    
    //Creates a session for other devices to join
    func advertise() {
        nearbyServiceAdvertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: ServiceType)
        nearbyServiceAdvertiser?.delegate = self
        nearbyServiceAdvertiser?.startAdvertisingPeer()
    }
    
    //Find and join an open session
    func join() {
        let browser = MCBrowserViewController(serviceType: ServiceType, session: session)
        browser.delegate = self
        UIApplication.shared.windows.first?.rootViewController?.present(browser , animated: true)
    }
    
    //packages the message to be sent to the connected peer. The message is that the user "DidSwipeNo"
    func didSwipeNo(at msg: String) {
        print("I am sending no")
        if let msgData = msg.data(using: .utf8) {
            try? session.send(msgData, toPeers: session.connectedPeers, with: .reliable)
        }
    }
    
    //packages the message to be sent to the connected peer. The message is that the user "DidSwipeYes"
    func didSwipeYes(at msg: String) {
        print("I am sending yes")
        if let msgData = msg.data(using: .utf8) {
            try? session.send(msgData, toPeers: session.connectedPeers, with: .reliable)
        }
    }
}


extension TinderViewModel: MCSessionDelegate {
    //when connecting to a device, keep track of all states of connectivity
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
    
    //calls whenever the device receives a set of data during the session
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print("didReceive Data from \(peerID)")
        if let msg = String(data: data, encoding: .utf8){
            print("received: \(msg)")
            let theirResponse = msg
        
            DispatchQueue.main.async {
                //self.checkIfMatch(msg:self.theirResponse ?? "undecided",myResponse:self.myResponse ?? "undecided")
                //self.myResponse = "undecided"
            }
        }
    }
    
    //stubbed protocol function
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
    }
    //stubbed protocol function
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
    }
    //stubbed protocol function
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
    }
}

extension TinderViewModel: MCNearbyServiceAdvertiserDelegate {
    //protocol function for when the user has created a session
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, session)
    }
}

extension TinderViewModel: MCBrowserViewControllerDelegate {
    //
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
