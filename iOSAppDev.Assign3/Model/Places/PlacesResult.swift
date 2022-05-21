//
//  PlacesResult.swift
//  iOSAppDev.Assign3
//
//  Created by John Balla on 21/5/2022.
//

import Foundation

struct PlacesResult: Codable {
    let results: [Place]
    enum resultCodingKey: String, CodingKey {
        case results = "results"
    }
}
