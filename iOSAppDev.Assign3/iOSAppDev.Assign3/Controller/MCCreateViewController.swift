//
//  MCCreateViewController.swift
//  iOSAppDev.Assign3
//
//  Created by Nicholas on 5/5/22.
//

import UIKit
import MultipeerConnectivity
import SwiftUI
import Combine
import GooglePlaces
import CoreLocation

class MCCreateViewController: UIViewController, CLLocationManagerDelegate{

    @IBOutlet weak var UIView: UIView!
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                CardView(TinderVM: TinderViewModel(), proxy: proxy, restaurant: Restaurant.restaurants[0], index: 0, onRemove: nil)
            }
        }
    }
    
    // handles access to location services within app, holds user location
    let locationManager = CLLocationManager()
    var placesClient: PlacesRequest = PlacesClient()
    var currentLocation: CLLocation = CLLocation(latitude: 00.000000, longitude: 00.000000)
    var searchRadius: Int = 5000
    var placeType: String = "restaurant"
    
    // session
    var peerID: MCPeerID!
    var session: MCSession!
    var nearbyServiceAdvertiser: MCNearbyServiceAdvertiser!
    var myResponse:String? = "undecided"
    var theirResponse:String? = "undecided"
    
    private var cancellable: AnyCancellable!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // request authorization for location when in use
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        checkLocationAuthorizationStatus(status: locationManager.authorizationStatus)
        locationManager.startUpdatingLocation()
        // if authorized, find the current location, and fetch data
        if(locationManager.authorizationStatus == .authorizedWhenInUse) {
            currentLocation = locationManager.location!
            fetchPlacesData(type: placeType, location: currentLocation, radius: searchRadius)
        }
        locationManager.stopUpdatingLocation()
        
        let delegate = ContentViewDelegate()
        peerID = MCPeerID(displayName: UIDevice.current.name)
        session = MCSession(peer: peerID)
        session.delegate = self
        let contentView = UIHostingController(rootView: ContentView(TinderVM: TinderViewModel()))
        addChild(contentView)
        contentView.view.frame = UIView.bounds
        UIView.addSubview(contentView.view)
        contentView.didMove(toParent: self)
        
        //self.cancellable = delegate.$myResponseSwipe.sink { myResponseSwipe in
        //    print ("sent \(myResponseSwipe)")
        //}
    }
    
    // Handle location update
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            currentLocation = CLLocation(latitude: latitude, longitude: longitude)
        }
    }
    
    // Handle failure to get a user’s location
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {

    }
    
    // Handle changes in authorization status
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorizationStatus(status: locationManager.authorizationStatus)
    }

    // error checking for authorization status
    func checkLocationAuthorizationStatus(status: CLAuthorizationStatus)  {
        switch status {
        case .restricted, .denied:
            print("restricted or denied")
            acceptLocationError(title: "Location Authorization Denied", message: "Please go to settings and enable location services for this application to function")
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            checkLocationAuthorizationStatus(status: locationManager.authorizationStatus)
        case .authorizedAlways:
            print("error, should not authorize always")
            acceptLocationError(title: "Location Authorization Set to Always", message: "This application does not request 'always' access of your location, please investigate")
        default:
            print("authorized location when in use")
        }
    }
    
    // shows error if there is an allow location acceptance issue
    @IBAction func acceptLocationError(title: String, message: String) {
        let alertController: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction: UIAlertAction = UIAlertAction(title: "OK", style: .default) { (action) -> Void in NSLog("OK was selected")}
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                        return
                    }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl)
            }
        }
        alertController.addAction(okAction)
        alertController.addAction(settingsAction)
        self.present(alertController, animated: true, completion: nil)
    }

    //creates a new session that is discoverable by other devices using the same app
    @IBAction func advertise(_ sender: Any) {
        nearbyServiceAdvertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: "food-tinder")
        nearbyServiceAdvertiser.delegate = self
        nearbyServiceAdvertiser.startAdvertisingPeer()
    }
    
    //search for any open sessions
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
    
    
    //function gets both the client's response and the connected peer's response and compares the two
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
    
    //after both have made a decision reset both responses
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

extension MCCreateViewController {
    // requests data from the google places web api and decodes it
    func fetchPlacesData(type: String, location: CLLocation, radius: Int) {
        placesClient.getPlacesData(forType: type,location: location, withinMeters: radius) { (response) in
            //self.printResults(places: response.results)
        }
     }
    
    // for testing purposes, uncomment this function in fetchPlacesData to print to command line
    func printResults(places: [Place]) {
        for place in places {
            print("*******NEW PLACE********")
            let name = place.name
            let type = place.types[0]
            let address = place.address
            let location: CLLocation = CLLocation(latitude: place.geometry.location.latitude, longitude: place.geometry.location.longitude)
            let distance = round(Double(location.distance(from: self.currentLocation)))
            print("\(name) is a \(type) located at \(address), \(distance)m away")
        }
    }
}
