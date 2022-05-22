//
//  TestViewController.swift
//  iOSAppDev.Assign3
//
//  Created by John Balla on 3/5/2022.
//

import UIKit
import GooglePlaces
import CoreLocation
import Foundation


class TestViewController: UIViewController, CLLocationManagerDelegate  {
    // labels to display info
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var priceRangeLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var websiteLabel: UILabel!
    @IBOutlet weak var placeImageView: UIImageView!
    
    // handles access to location services within app, holds user location
    let locationManager = CLLocationManager()
    var placesClient: PlacesRequest = PlacesClient()
    var currentLocation: CLLocation = CLLocation(latitude: 00.000000, longitude: 00.000000)
    var searchRadius: Int = 5000
    var placeType: String = "restaurant"

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
    }
    
    func updateLabels(name: String) {
        nameLabel.text = name
        //hoursLabel.text = place.openingHours
        //ratingLabel.text = ""
        //priceRangeLabel.text = ""
        //phoneLabel.text = ""
        //websiteLabel.text = ""
        //placeImageView =
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

    func checkLocationAuthorizationStatus(status: CLAuthorizationStatus)  {
        // error checking for authorization status
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
}


extension TestViewController {
     
    func fetchPlaces(type: String, location: CLLocation, radius: Int) {
        placesClient.getPlacesData(forType: type,location: location, withinMeters: radius) { (response) in
            response.results

        }
    }
    
    func fetchPlacesData(type: String, location: CLLocation, radius: Int) {
        placesClient.getPlacesData(forType: type,location: location, withinMeters: radius) { (response) in
            self.printResults(places: response.results)
        }
     }
    
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

//    // google places sdk interface, GMS (google mobile services)
//    private var placesClient: GMSPlacesClient!

// localize places interface to view when loading in
//placesClient = GMSPlacesClient.shared()

//    // on load, loads current location name and formatted address
//    func getCurrentPlace() {
//        let placeFields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
//                                                                 UInt(GMSPlaceField.placeID.rawValue) |
//                                                                 UInt(GMSPlaceField.coordinate.rawValue))
//        placesClient.findPlaceLikelihoodsFromCurrentLocation(withPlaceFields: placeFields) { [weak self] (placeLikelihoods, error) in
//            guard let strongSelf = self else {
//                return
//            }
//
//            guard error == nil else {
//                print("Current place error: \(error?.localizedDescription ?? "")")
//                return
//            }
//
//            guard let place = placeLikelihoods?.first?.place else {
//                strongSelf.nameLabel.text = "No current place"
//                strongSelf.hoursLabel.text = ""
//                strongSelf.ratingLabel.text = ""
//                strongSelf.priceRangeLabel.text = ""
//                strongSelf.phoneLabel.text = ""
//                strongSelf.websiteLabel.text = ""
//                return
//            }
//            strongSelf.nameLabel.text = place.name
//            //strongSelf.hoursLabel.text = place.openingHours
//            //strongSelf.ratingLabel.text = ""
//            //strongSelf.priceRangeLabel.text = ""
//            //strongSelf.phoneLabel.text = ""
//            //strongSelf.websiteLabel.text = ""
//            //strongSelf.placeImageView =
//        }
//    }
    
