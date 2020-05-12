//
//  SearchResponse.swift
//  VirutalTouristNoStoryBoard
//
//  Created by LALIT JAGTAP on 5/7/20.
//  Copyright © 2020 LALIT JAGTAP. All rights reserved.
//

import Foundation

// MARK: - SearchResponse
struct SearchResponse: Codable {
    let photos: JSONPhotos
    let stat: String
}

// MARK: - Photos
struct JSONPhotos: Codable {
    let page, pages, perpage: Int
    let total: String
    let photo: [JSONPhoto]
}
