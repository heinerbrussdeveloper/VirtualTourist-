//
//  Pin.swift
//  VirtualTourist
//
//  Created by Heiner Bruß on 28.08.20.
//  Copyright © 2020 Heiner Bruß. All rights reserved.
//

import MapKit

class MapPin: NSObject, MKAnnotation {
   let title: String?
   let locationName: String
   let coordinate: CLLocationCoordinate2D
init(title: String, locationName: String, coordinate: CLLocationCoordinate2D) {
      self.title = title
      self.locationName = locationName
      self.coordinate = coordinate
   }
}

