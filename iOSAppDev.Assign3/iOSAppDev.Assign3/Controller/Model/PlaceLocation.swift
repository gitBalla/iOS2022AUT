//
//  PlaceLocation.swift
//  iOSAppDev.Assign3
//
//  Created by John Balla on 21/5/2022.
//

import Foundation

struct PlaceLocation : Codable {
        
        let location : LatLong
        
        enum CodingKeys : String, CodingKey {
            case location = "location"
        }
        
        struct LatLong : Codable {
            
            let latitude : Double
            let longitude : Double
            
            enum CodingKeys : String, CodingKey {
                case latitude = "lat"
                case longitude = "lng"
            }
        }
    }
