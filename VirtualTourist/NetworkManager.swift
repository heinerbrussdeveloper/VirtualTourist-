//
//  NetworkManager.swift
//  VirtualTourist
//
//  Created by Heiner Bruß on 28.08.20.
//  Copyright © 2020 Heiner Bruß. All rights reserved.
//

import UIKit

class NetworkManager {
    
static let shared = NetworkManager()
    
    private init() {
        
    }
    
    let apiKey = "3e4498b89726d44a3b504fc5be29fd1c"
    let baseUrl = "https://api.flickr.com/services/rest/"
    let search =  "flickr.photos.search"
    
    func getFlickrPics(latitude: Double, longitude: Double, page: Int, completion: @escaping ([FlickrPhoto]?, Error?) -> Void) {
        let urlString: String = "\(baseUrl)?api_key=\(apiKey)&method=\(search)&format=json&lat=\(latitude)&lon=\(longitude)&radius=10&nojsoncallback=1&page=\(page)"
        
        guard let url = URL(string: urlString)  else {return}
       
        print(url)
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let downloadError = error {
                completion(nil, downloadError)
            }
            guard let data = data else {
                completion(nil, error)
                return
            }
            do {
                let responseObject = try JSONDecoder().decode(JsonFlickrApiRequest.self, from: data)
                print(responseObject)
                
                let photoCollection = Array(responseObject.photos.photo.prefix(100))
                completion(photoCollection, nil)
            } catch {
                completion(nil, error)
            }
        }
        task.resume()
    }
}
