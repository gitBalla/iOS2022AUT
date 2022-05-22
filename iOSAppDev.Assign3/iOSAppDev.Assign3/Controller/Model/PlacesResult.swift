//
//  PlacesResult.swift
//  iOSAppDev.Assign3
//
//  Created by John Balla on 21/5/2022.
//
//  decodes the result of the google api call into a 'Place' array
//  which can be further decoded into 'Place'

import Foundation

struct PlacesResult: Codable {
    let results: [Place]
    enum resultCodingKey: String, CodingKey {
        case results = "results"
    }
}
