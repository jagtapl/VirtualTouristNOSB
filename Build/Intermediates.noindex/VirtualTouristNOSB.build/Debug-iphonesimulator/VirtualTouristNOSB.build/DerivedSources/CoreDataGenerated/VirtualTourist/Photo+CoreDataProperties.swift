//
//  Photo+CoreDataProperties.swift
//  
//
//  Created by LALIT JAGTAP on 5/11/20.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo")
    }

    @NSManaged public var image: Data?
    @NSManaged public var imageUrl: String?
    @NSManaged public var pin: Pin?

}
