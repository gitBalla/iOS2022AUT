//
//  TestViewController.swift
//  iOSAppDev.Assign3
//
//  Created by John Balla on 3/5/2022.
//

import UIKit
import Alamofire
import GooglePlaces
import CoreLocation
import Foundation


class TestViewController: UIViewController, CLLocationManagerDelegate  {
    // labels to display info
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var addressLabel: UILabel!
    @IBOutlet weak var placeImageView: UIImageView!
    // google places interface
    private var placesClient: GMSPlacesClient!
    // handles access to location services within app
    let locationManager = CLLocationManager()
    
    //testing new web api call
    var placesClientWeb: PlacesRequest = PlacesClient()
    var currentLocation: CLLocation = CLLocation(latitude: 42.361145, longitude: -71.057083)
    var radius: Int = 2500
    var placeType: String = "restaurant"

    override func viewDidLoad() {
        super.viewDidLoad()
        // localize places interface to view when loading in
        placesClient = GMSPlacesClient.shared()

        // request authorization for location when in use
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()

        // error checking for authorization status
        switch locationManager.authorizationStatus {
        case .restricted, .denied:
            print("restricted or denied")
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedAlways:
            print("error, should not authorize always")
        default:
            print("authorized location when in use")
            getCurrentPlace()
            fetchPlacesData(forType: placeType, forLocation: currentLocation, searchRadius: radius)
        }
    }
    
    // handles changes in authorization status
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
    {

    }

    // on load, loads current location name and formatted address
    func getCurrentPlace() {
        let placeFields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
                                                       UInt(GMSPlaceField.placeID.rawValue) |
                                                       UInt(GMSPlaceField.coordinate.rawValue))
        placesClient.findPlaceLikelihoodsFromCurrentLocation(withPlaceFields: placeFields) { [weak self] (placeLikelihoods, error) in
            guard let strongSelf = self else {
                return
            }

            guard error == nil else {
                print("Current place error: \(error?.localizedDescription ?? "")")
                return
            }

            guard let place = placeLikelihoods?.first?.place else {
                strongSelf.nameLabel.text = "No current place"
                strongSelf.addressLabel.text = ""
                return
            }
            strongSelf.nameLabel.text = place.name
            strongSelf.addressLabel.text = String(place.coordinate.latitude) + ", " + String(place.coordinate.longitude)
        }
    }
}


extension TestViewController {
    func fetchPlacesData(forType: String, forLocation: CLLocation, searchRadius: Int) {
        
         placesClientWeb.getPlacesData(forType: placeType,location: currentLocation, withinMeters: 2500) { (response) in
             
             self.printFirstFive(places: response.results)
             
         }
     }
    func printFirstFive(places: [Place]) {
            for place in places{
                print("*******NEW PLACE********")
                let name = place.name
                let address = place.address
                let location = ("lat: \(place.geometry.location.latitude), lng: \(place.geometry.location.longitude)")
                print("\(name) is located at \(address), \(location)")
             }
         }
}
