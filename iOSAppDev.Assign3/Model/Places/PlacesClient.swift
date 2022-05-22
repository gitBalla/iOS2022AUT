//
//  GooglePlacesRequest.swift
//  iOSAppDev.Assign3
//
//  Created by John Balla on 21/5/2022.
//

import Foundation
import CoreLocation

protocol PlacesRequest {

    var placesKey : String { get set }
    func getPlacesData(forType placeType: String, location: CLLocation, withinMeters radius: Int, using completionHandler: @escaping (PlacesResult) -> ())
    
}

class PlacesClient : PlacesRequest {
 
    let session = URLSession(configuration: .default)

    var placesKey: String = "YOUR_API_KEY"

    func getPlacesData(forType placeType: String, location: CLLocation,withinMeters radius: Int, using completionHandler: @escaping (PlacesResult) -> ())  {
        
        let url = placesURL(forKey: placesKey, location: location, radius: radius, placeType: placeType)

        let task = session.dataTask(with: url) { (responseData, _, error) in
                                               
            if let error = error {
                print(error.localizedDescription)
                return
            }
                                               
            guard let data = responseData,
                let response = try? JSONDecoder().decode(PlacesResult.self, from: data) else {
                completionHandler(PlacesResult(results:[]))
                    print("Failed handler")
                    return
            }
            completionHandler(response)
       }
       task.resume()
   }
        
    //forms the url request, output to json, search by keyword (type), based on location and rank results by distance
    func placesURL(forKey apiKey: String, location: CLLocation, radius: Int, placeType: String) -> URL {
        let baseURL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?"
        let type = "keyword=" + placeType
        let locationString = "location=" + String(location.coordinate.latitude) + "," + String(location.coordinate.longitude)
        //let searchRadius = "radius=" + String(radius)  //conflicts with rankby
        let key = "key=" + apiKey
        let rankby = "rankby=distance" //conflicts with searchRadius
        return URL(string: baseURL + type + "&" + locationString + "&" + rankby + "&" + key)!
    }

}
