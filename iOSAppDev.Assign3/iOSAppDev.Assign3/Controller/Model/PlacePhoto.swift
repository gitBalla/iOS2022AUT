//
//  PlacePhotos.swift
//  iOSAppDev.Assign3
//
//  Created by John Balla on 21/5/2022.
//
//  decodes the Place photo data into usable references and data

import Foundation

struct PlacePhoto : Codable {
  
    let height : Int
    let width : Int
    let photoReference : String

    enum CodingKeys : String, CodingKey {
      case height = "height"
      case width = "width"
      case photoReference = "photo_reference"
    }
}
