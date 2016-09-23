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
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        let entity =  NSEntityDescription.entity(forEntityName: "ImageInfo", in: context)!
        
        super.init(entity: entity, insertInto: context)
        
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
