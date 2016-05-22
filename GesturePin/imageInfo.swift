//
//  imageInfo.swift
//  GesturePin
//
//  Created by Xiaochao Luo on 2016-05-09.
//  Copyright © 2016 Xiaochao Luo. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class ImageInfo: NSManagedObject {
    
    
    @NSManaged var imageURL: String!
    @NSManaged var pinPoint: Pin?
//    var title: String?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        // Get the entity associated with the "Person" type.  This is an object that contains
        // the information from the Model.xcdatamodeld file. We will talk about this file in
        // Lesson 4.
        let entity =  NSEntityDescription.entityForName("ImageInfo", inManagedObjectContext: context)!
        
        // Now we can call an init method that we have inherited from NSManagedObject. Remember that
        // the Person class is a subclass of NSManagedObject. This inherited init method does the
        // work of "inserting" our object into the context that was passed in as a parameter
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    
        imageURL = dictionary["url_m"] as? String
//        title = dictionary["title"] as? String
        
    }
    
    var posterImage: UIImage? {
        get {
            return VirtualTouristClient.Caches.imageCache.imageWithIdentifier(imageURL)
        }
        set {
            VirtualTouristClient.Caches.imageCache.storeImage(newValue, withIdentifier: imageURL!)
        }
    }
    
//    static func imagesFromResults(results: [[String:AnyObject]]) -> [imageInfo]{
//        
//        var info = [imageInfo]()
//        for result in results {
//            info.append(imageInfo(dictionary: result))
//            
//        }
//        return info
//    }
    
    

    
    
    
    
    
    
    
    
    
    
    
    
}