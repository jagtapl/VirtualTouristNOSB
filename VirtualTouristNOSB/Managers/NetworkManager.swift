//
//  NetworkManager.swift
//  FollowersGITHUB
//
//  Created by LALIT JAGTAP on 2/3/20.
//  Copyright © 2020 LALIT JAGTAP. All rights reserved.
//

import Foundation
import UIKit

class NetworkManager {
    static let shared = NetworkManager()
    
    static var prevSearchResponse: SearchResponse!
    
    private init() {
        // to make sure only one instance is created
    }
    
    struct Params {
        static let method = "?method=flickr.photos.search"
        static let apiKey = "&api_key=029a16907bf3a37250cd8381349d098f"
        static let extras = "&extras=url_m"
        static let format = "&format=json"
        static let nojsoncallback = "&nojsoncallback=1"
        static let per_page = "&per_page=24"
    }
    
    enum Endpoints {
        static let base = "https://api.flickr.com/services/rest"
        
        case search(Double, Double, Int)
        
        var stringValue: String {
            switch self {
            case .search(let lat, let lon, let page):
                return Endpoints.base + Params.method + Params.apiKey +
                    "&lat=\(lat)" + "&lon=\(lon)" + Params.extras + Params.format + Params.nojsoncallback + Params.per_page + "&page=\(page)"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    
    func downloadRawImageData(from fromUrl: String, completed: @escaping (Data?) -> Void) {
        guard let url = URL(string: fromUrl) else {
            completed(nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard error == nil,
                let response = response as? HTTPURLResponse, response.statusCode == 200,
                let data = data else {
                    completed(nil)
                    return
                }
            
            completed(data)
        }
        
        task.resume()
    }
        
    func searchPhotos(lattitude: Double, longitude: Double, page: Int, completed: @escaping (Result<JSONPhotos, LJError>) -> Void) {

        let url = NetworkManager.Endpoints.search(lattitude, longitude, page).url
        print("search photos using :\(url)")
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let _ = error {
                completed(.failure(.unableToComplete))
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completed (.failure(.unableToComplete))
                return
            }
            
            guard let data = data else {
                completed(.failure(.invalidData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let searchResponse = try decoder.decode(SearchResponse.self, from: data)
                NetworkManager.self.prevSearchResponse = searchResponse
                completed(.success(searchResponse.photos))

            } catch let DecodingError.keyNotFound(type, context) {
                print("Type \(type) mismatch:", context.debugDescription)
                print("codingPath:", context.codingPath)
                completed(.failure(.invalidFieldName))
            } catch let DecodingError.typeMismatch(type, context) {
                print("Type \(type) mismatch:", context.debugDescription)
                print("codingPath:", context.codingPath)
                completed(.failure(.invalidValueType))
            } catch {
                completed(.failure(.invalidData))
            }
        }
        
        task.resume()
    }
}
