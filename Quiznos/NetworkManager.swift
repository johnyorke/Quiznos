//
//  API.swift
//  Quiznos
//
//  Created by John Yorke on 17/01/2017.
//  Copyright © 2017 John Yorke. All rights reserved.
//

import Foundation

class NetworkManager {
    
    static let shared = NetworkManager()
    
    func getJSON(fromUrl url: URL, completion: @escaping (([String : AnyObject]) -> Void)) {
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as! [String : AnyObject]
                completion(json)
            } catch {
                print("Uh oh. An error occured deserialising JSON")
            }
            }.resume()
    }
    
}
