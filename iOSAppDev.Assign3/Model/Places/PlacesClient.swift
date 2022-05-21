//
//  GooglePlacesRequest.swift
//  iOSAppDev.Assign3
//
//  Created by John Balla on 21/5/2022.
//

import Foundation
import CoreLocation
//import Alamofire

protocol PlacesRequest {

    var placesKey : String { get set }
    func getPlacesData(/*forKeyword keyword: String,*/ forType placeType: String, location: CLLocation, withinMeters radius: Int, using completionHandler: @escaping (PlacesResult) -> ())
    
}

class PlacesClient : PlacesRequest {
 
    let session = URLSession(configuration: .default)

    var placesKey: String = "AIzaSyCO7VyaREQgfumMiDbACVCUuDtoQe_Qolk"

    func getPlacesData(forType placeType: String, location: CLLocation,withinMeters radius: Int, using completionHandler: @escaping (PlacesResult) -> ())  {
        
        let url = placesURL(forKey: placesKey, location: location, radius: radius, placeType: placeType)
//        AF.request(url).responseDecodable(of: PlacesResult.self) { response in
//
//        }
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
        
    func placesURL(forKey apiKey: String, location: CLLocation, /*keyword: String,*/ radius: Int, placeType: String) -> URL {
        
        let baseURL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?"
        //let urlKeyword = "keyword=" + keyword
        let locationString = "location=" + String(location.coordinate.latitude) + "," + String(location.coordinate.longitude)
        let searchRadius = "radius=" + String(radius)
        let type = "type=" + placeType
        let rankby = "rankby=distance"
        let key = "key=" + apiKey

        return URL(string: baseURL + /*urlKeyword + "&" +*/ locationString + "&" + searchRadius + "&" + type + "&" + rankby + "&" + key)!
    }

}
