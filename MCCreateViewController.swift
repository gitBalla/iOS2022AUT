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

class MCCreateViewController: UIViewController, CardSliderDataSource  {

    @IBOutlet var myButton: UIButton!
    
    var data = [Item]()
    
    var peerID: MCPeerID!
    var session: MCSession!
    //var advertiserAssistant: MCAdvertiserAssistant!
    var nearbyServiceAdvertiser: MCNearbyServiceAdvertiser!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        peerID = MCPeerID(displayName: UIDevice.current.name)
        session = MCSession(peer: peerID)
        session.delegate = self

        data.append(Item(image: UIImage(named: "Restaurant")!,
                               rating: 1,
                               title: "Restaurants",
                               subtitle: "Which one is best for the two of you?",
                               description: "You able to pick and save the cuisine of interest"))

              data.append(Item(image: UIImage(named: "Restaurant")!,
                               rating: 1,
                               title: "Restaurants",
                               subtitle: "Which one is best for the two of you?",
                               description: "You able to pick and save the cuisine of interest"))

              data.append(Item(image: UIImage(named: "Restaurant")!,
                               rating: 1,
                               title: "Restaurants",
                               subtitle: "Which one is best for the two of you?",
                               description: "You able to pick and save the cuisine of interest"))

        myButton.backgroundColor = .link
        myButton.setTitleColor(.white, for: .normal)
    }
    
    @IBAction func didTapButton() {
    //Present the card slider
        let vc = CardSliderViewController.with(dataSource: self);    vc.title = "About"
    vc.modalPresentationStyle = .fullScreen
    present(vc, animated: true)
    }
    
    func item(for index: Int) -> CardSliderItem {
           return data[index]
       }

       func numberOfItems() -> Int {
           return data.count
       }
    
    @IBAction func advertise(_ sender: Any) {
        nearbyServiceAdvertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: "gt-chess")
        nearbyServiceAdvertiser.delegate = self
        nearbyServiceAdvertiser.startAdvertisingPeer()
    }
    
    @IBAction func join(_ sender: Any) {
        let browser = MCBrowserViewController(serviceType: "gt-chess", session: session)
        browser.delegate = self
        present(browser, animated: true)
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
