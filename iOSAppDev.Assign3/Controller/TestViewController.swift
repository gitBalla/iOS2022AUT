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

    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var addressLabel: UILabel!

    private var placesClient: GMSPlacesClient!
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
      super.viewDidLoad()
      placesClient = GMSPlacesClient.shared()
      
      // request authorization for location when in use
      locationManager.requestWhenInUseAuthorization()
      locationManager.delegate = self
      locationManager.startUpdatingLocation()

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
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
    {

    }


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
