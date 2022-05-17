//
//  TestViewController.swift
//  iOSAppDev.Assign3
//
//  Created by John Balla on 3/5/2022.
//

import GooglePlaces
import UIKit
import CoreLocation


class TestViewController: UIViewController, CLLocationManagerDelegate  {
    // labels to display info
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var addressLabel: UILabel!
    // google places interface
    private var placesClient: GMSPlacesClient!
    // handles access to location services within app
    let locationManager = CLLocationManager()

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
        }
    }
    
    // handles changes in authorization status
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
    {

    }

    // on button press loads current location name and formatted address
    @IBAction func getCurrentPlace(_ sender: UIButton) {
      let placeFields: GMSPlaceField = [.name, .formattedAddress]
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
        strongSelf.addressLabel.text = place.formattedAddress
      }
    }
}
