//
//  Pin.swift
//  GesturePin
//
//  Created by Xiaochao Luo on 2016-05-10.
//  Copyright © 2016 Xiaochao Luo. All rights reserved.
//

import Foundation
import CoreData
import MapKit


class Pin: NSManagedObject{

    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    @NSManaged var title: String?
    @NSManaged var imageinfos: [ImageInfo]
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(dictionary: [String:AnyObject], context: NSManagedObjectContext){
        
        let entity =  NSEntityDescription.entity(forEntityName: "Pin", in: context)!
        
        super.init(entity: entity, insertInto: context)
        
        latitude = dictionary["latitude"] as! NSNumber
        longitude = dictionary["longitude"] as! NSNumber
        title = dictionary["title"] as? String
        
    }
    
    
    
}

//    init(annotationLatitude: Double, annotationLongitude: Double, context: NSManagedObjectContext) {
//
//        let entity = NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
//        super.init(entity: entity, insertIntoManagedObjectContext: context)
//
//        latitude = NSNumber(double: annotationLatitude)
//        longitude = NSNumber(double: annotationLongitude)
//    }
//
//    var coordinate: CLLocationCoordinate2D{
//        return CLLocationCoordinate2D(latitude: latitude as Double, longitude: longitude as Double)
//    }
