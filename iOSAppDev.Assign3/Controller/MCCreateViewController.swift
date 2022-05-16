//
//  MCCreateViewController.swift
//  iOSAppDev.Assign3
//
//  Created by Nicholas on 5/5/22.
//

import UIKit
import MultipeerConnectivity

class MCCreateViewController: UIViewController {

    
    var peerID: MCPeerID!
    var session: MCSession!
    //var advertiserAssistant: MCAdvertiserAssistant!
    var nearbyServiceAdvertiser: MCNearbyServiceAdvertiser!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        peerID = MCPeerID(displayName: UIDevice.current.name)
        session = MCSession(peer: peerID)
        session.delegate = self

    }
    
    
    @IBAction func advertise(_ sender: Any) {
        nearbyServiceAdvertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: "food-tinder")
        nearbyServiceAdvertiser.delegate = self
        nearbyServiceAdvertiser.startAdvertisingPeer()
    }
    
    @IBAction func join(_ sender: Any) {
        let browser = MCBrowserViewController(serviceType: "food-tinder", session: session)
        browser.delegate = self
        present(browser, animated: true)
    }
    @IBAction func didPressNo(_ sender: Any) {
        let msg = "didPressNo"
        if let msgData = msg.data(using: .utf8) {
            try? session.send(msgData, toPeers: session.connectedPeers, with: .reliable)
        }
    }
    @IBAction func didPressYes(_ sender: Any) {
        let msg = "didPressYes"
        if let msgData = msg.data(using: .utf8) {
            try? session.send(msgData, toPeers: session.connectedPeers, with: .reliable)
        }
    }
}


extension MCCreateViewController: MCBrowserViewControllerDelegate {
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
            dismiss(animated: true)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
            dismiss(animated: true)
    }
}

extension MCCreateViewController: MCSessionDelegate {
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            print("Connected: \(peerID.displayName)")
        case .connecting:
            print("Connecting: \(peerID.displayName)")
        case .notConnected:
            print("Not Connected: \(peerID.displayName)")
        @unknown default:
            print("Fatal error :(")
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print("didReceive Data")
        if let msg = String(data: data, encoding: .utf8){
            print("received: \(msg)")
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
    }
}

extension MCCreateViewController: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, session)
    }
    
    
}
