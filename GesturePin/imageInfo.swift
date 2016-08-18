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
    @NSManaged var id: String!
    @NSManaged var pinPoint: Pin?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        let entity =  NSEntityDescription.entityForName("ImageInfo", inManagedObjectContext: context)!
        
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        id = dictionary["id"] as? String
        imageURL = dictionary["url_m"] as? String
        
    }
    
    var posterImage: UIImage? {
        get {
            return VirtualTouristClient.Caches.imageCache.imageWithIdentifier(id)
        }
        set {
        VirtualTouristClient.Caches.imageCache.storeImage(newValue, withIdentifier: id)
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