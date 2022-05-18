//
//  TestMenuViewController.swift
//  iOSAppDev.Assign3
//
//  Created by John Balla on 16/5/2022.
//

import GooglePlaces
import UIKit
import CoreLocation


class TestMenuViewController: UIViewController, CLLocationManagerDelegate {


    @IBOutlet var testMenuTableView: UITableView!
    @IBOutlet weak var placeImageView: UIImageView!
    
    //
    private var placeLikelihoods: [GMSPlaceLikelihood]?
    
    // google places interface
    private var placesClient: GMSPlacesClient!
    // handles access to location services within app
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        testMenuTableView.dataSource = self
        testMenuTableView.delegate = self
        
        // localize places interface to view when loading in
        placesClient = GMSPlacesClient.shared()
        
        locationManager.delegate = self
          
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
        loadLikelihoodFromCurrentLocation()
    }
    
    @objc func loadLikelihoodFromCurrentLocation() {
        // request authorization for location when in use
        guard CLLocationManager.locationServicesEnabled() else {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        locationManager.startUpdatingLocation()

        let placeFields: GMSPlaceField = [.name, .types, .photos]
         
        placesClient.findPlaceLikelihoodsFromCurrentLocation(withPlaceFields: placeFields) {
            [weak self] (list, error) -> Void in
            guard let strongSelf = self else { return }
            
            strongSelf.placeLikelihoods = list?.filter { likelihood in
              !(likelihood.place.name?.isEmpty ?? true)
                && (likelihood.place.types?.contains("restaurant") ?? true)
            }
            
            self!.testMenuTableView.reloadData()
        }
        
    }
}



extension TestMenuViewController: UITableViewDelegate {
    func testMenuTableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
}


extension TestMenuViewController: UITableViewDataSource {
    
    // tells the table how many rows to have, only if under 10
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let likelihoods = placeLikelihoods else {
          return 0
        }
        return likelihoods.count
    }
    
    // tells the table what to display in each cell at an index
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Deque a reusable cell from the table view
        let cell = tableView.dequeueReusableCell(withIdentifier: "restaurantCell", for: indexPath)
        // Updated the UI for this cell
        cell.textLabel?.numberOfLines = 0
        guard let likelihoods = placeLikelihoods else {
          return cell
        }
        if likelihoods.count >= 0 && indexPath.row < likelihoods.count {
            cell.textLabel?.text = likelihoods[indexPath.row].place.name
        }
        
        // Return the cell to TableView
        return cell;
    }
    
    // Create a standard header that includes the returned text.
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Local Restaurants"
    }

    
}
