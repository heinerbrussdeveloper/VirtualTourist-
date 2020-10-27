//
//  FlickrAPIRequest.swift
//  VirtualTourist
//
//  Created by Heiner Bruß on 01.09.20.
//  Copyright © 2020 Heiner Bruß. All rights reserved.
//

import UIKit


struct JsonFlickrApiRequest: Codable {
    let photos: FlickrPhotoResponse
}

struct FlickrPhotoResponse: Codable {
    let page: Int
    let pages: Int
    let photo: [FlickrPhoto]
}

struct FlickrPhoto: Codable {
    let id: String
    let secret: String
    let server: String
    let farm: Int
 
    func imageURLString() -> String {
        return "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)_q.jpg"
    }
    
}
