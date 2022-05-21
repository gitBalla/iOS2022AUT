//
//  MCCreateViewController.swift
//  iOSAppDev.Assign3
//
//  Created by Nicholas on 5/5/22.
//

import UIKit
import MultipeerConnectivity
import CardSlider

struct Item: CardSliderItem {
    var image: UIImage
    var rating: Int?
    var title: String
    var subtitle: String?
    var description: String?
}

class MCCreateViewController: UIViewController, CardSliderDataSource{
    
    var peerID: MCPeerID!
    var session: MCSession!
    var nearbyServiceAdvertiser: MCNearbyServiceAdvertiser!
    var myResponse:String? = "undecided"
    var theirResponse:String? = "undecided"
    
    var data = [Item]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        peerID = MCPeerID(displayName: UIDevice.current.name)
        session = MCSession(peer: peerID)
        session.delegate = self
        
        data.append(Item(image: UIImage(named: "Pizza")!,
                               rating: 1,
                               title: "Restaurants",
                               subtitle: "Which one is best for the two of you?",
                               description: "You able to pick and save the cuisine of interest"))

              data.append(Item(image: UIImage(named: "Indian")!,
                               rating: 1,
                               title: "Restaurants",
                               subtitle: "Which one is best for the two of you?",
                               description: "You able to pick and save the cuisine of interest"))

              data.append(Item(image: UIImage(named: "Salmon")!,
                               rating: 1,
                               title: "Restaurants",
                               subtitle: "Which one is best for the two of you?",
                               description: "You able to pick and save the cuisine of interest"))
    }
    
    @IBAction func didTapFindRestaurants(_ sender: Any) {
        let vc = CardSliderViewController.with(dataSource: self);
        vc.title = "Welcome!"
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
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
        myResponse = "No"
        if let msgData = msg.data(using: .utf8) {
            try? session.send(msgData, toPeers: session.connectedPeers, with: .reliable)
        }
        checkIfMatch(msg: theirResponse ?? "undecided", myResponse: myResponse ?? "undecided")
    }
    @IBAction func didPressYes(_ sender: Any) {
        let msg = "didPressYes"
        myResponse = "Yes"
        if let msgData = msg.data(using: .utf8) {
            try? session.send(msgData, toPeers: session.connectedPeers, with: .reliable)
        }
        checkIfMatch(msg: theirResponse ?? "undecided", myResponse: myResponse ?? "undecided")
    }
    
    func item(for index: Int) -> CardSliderItem {
        return data[index]
    }
    
    func numberOfItems() -> Int {
        return data.count
    }
    
    func checkIfMatch (msg:String, myResponse:String) -> Bool {
        if myResponse == "Yes" && msg == "didPressYes"{
            print("We have a Match!")
            resetResponses()
            return true
        } else if myResponse == "No" && msg == "didPressYes"{
            print("no match, go next")
            resetResponses()
            return false
        } else if myResponse == "No" && msg == "didPressNo"{
            print("no match, go next")
            resetResponses()
            return false
        } else if myResponse == "Yes" && msg == "didPressNo" {
            print("no match, go next")
            resetResponses()
            return false
        } else {
            print("waiting on peer to answer")
            return false
        }
    }

    func resetResponses () {
        myResponse = "undecided"
        theirResponse = "undecided"
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
        print("didReceive Data from \(peerID)")
        if let msg = String(data: data, encoding: .utf8){
            print("received: \(msg)")
            theirResponse = msg
            DispatchQueue.main.async {
                self.checkIfMatch(msg:self.theirResponse ?? "undecided",myResponse:self.myResponse ?? "undecided")
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

extension MCCreateViewController: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, session)
    }
    
    
}
