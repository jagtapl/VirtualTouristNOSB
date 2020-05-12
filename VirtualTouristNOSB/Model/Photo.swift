//
//  Photo.swift
//  VirutalTouristNoStoryBoard
//
//  Created by LALIT JAGTAP on 5/7/20.
//  Copyright © 2020 LALIT JAGTAP. All rights reserved.
//

import Foundation

// MARK: - Photo
struct JSONPhoto: Codable {
    let id: String
    let urlM: String

    enum CodingKeys: String, CodingKey {
        case id
        case urlM = "url_m"
    }
}

