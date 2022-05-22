//
//  Place.swift
//  iOSAppDev.Assign3
//
//  Created by John Balla on 21/5/2022.
//
//  decodes the result of the google api call into 'Place's which can be further decoded

import Foundation

struct Place : Codable {

    let geometry : PlaceLocation
    let name : String
    let photos : [PlacePhoto]
    let types : [String]
    let address : String
    
    enum CodingKeys : String, CodingKey {
        case geometry = "geometry"
        case name = "name"
        case photos = "photos"
        case types = "types"
        case address = "vicinity"
    }
}
