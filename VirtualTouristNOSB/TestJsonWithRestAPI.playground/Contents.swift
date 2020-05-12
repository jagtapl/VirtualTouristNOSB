import UIKit

var str = "Hello, playground"

// MARK: - SearchResponse
struct SearchResponse: Codable {
    let photos: Photos
    let stat: String
}

// MARK: - Photos
struct Photos: Codable {
    let page, pages, perpage: Int
    let total: String
    let photo: [Photo]
}

// MARK: - Photo
struct Photo: Codable {
    let id: String
//    let owner, secret, server: String
//    let farm: Int
//    let title: String
//    let ispublic, isfriend, isfamily: Int
    let urlM: String
//    let heightM, widthM: Int

    enum CodingKeys: String, CodingKey {
        case id
//        case owner, secret, server, farm, title, ispublic, isfriend, isfamily
        case urlM = "url_m"
//        case heightM = "height_m"
//        case widthM = "width_m"
    }
}


class NetworkManager {
    static let shared = NetworkManager()

    private init() {
        // to make sure only one instance is created
    }
    
    struct Params {
        static let method = "?method=flickr.photos.search"
        static let apiKey = "&api_key=029a16907bf3a37250cd8381349d098f"
        static let extras = "&extras=url_m"
        static let format = "&format=json"
        static let nojsoncallback = "&nojsoncallback=1"
    }
    
    enum Endpoints {
        static let base = "https://api.flickr.com/services/rest"
        
        case search(Float, Float)
        
        var stringValue: String {
            switch self {
            case .search(let lat, let lon):
                return Endpoints.base + Params.method + Params.apiKey +
                "&lat=\(lat)" + "&lon=\(lon)" + Params.extras + Params.format + Params.nojsoncallback
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
}

print ("search url is \(NetworkManager.Endpoints.search(42.1103, 88.0342).url)")

let url = NetworkManager.Endpoints.search(42.1103, 88.0342).url
let request = URLRequest(url: url)
let session = URLSession.shared

let task = session.dataTask(with: request) { data, response, error in
    if error != nil { // Handle error
        return
    }
    
//    print("print received data in readable .utf8")
//    print(String(data: data!, encoding: .utf8)!)
    
    // decode using Codable
    do {
            let decoder = JSONDecoder()
//            decoder.keyDecodingStrategy = .convertFromSnakeCase
//        decoder.dateDecodingStrategy = .iso8601
        
            guard let data = data else {
                print("failed to get data for student location")
                return
            }
        
            let searchResponse = try decoder.decode(SearchResponse.self, from: data)
//          completed(.success(user))
            print("decododed search response instance")
            let photos = searchResponse.photos
            for photo in photos.photo {
                print("photo \(photo)")
            }
            print ("stat of photos result")
            print ("stat \(searchResponse.stat)")
            print ("total \(searchResponse.photos.total)")
            print ("page \(searchResponse.photos.page)")
            print ("pages \(searchResponse.photos.pages)")
            print ("per page \(searchResponse.photos.perpage)")

            return

        } catch let DecodingError.keyNotFound(type, context) {
            print("Type \(type) mismatch:", context.debugDescription)
            print("codingPath:", context.codingPath)
//                completed(.failure(.invalidFieldName))
                return
        } catch let DecodingError.typeMismatch(type, context) {
            print("Type \(type) mismatch:", context.debugDescription)
            print("codingPath:", context.codingPath)
//                completed(.failure(.invalidValueType))
                return
        } catch {
            print("failed to decode JSON for photos")
        }
}
task.resume()
