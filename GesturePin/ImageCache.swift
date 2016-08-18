//
//  File.swift
//  FavoriteActors
//
//  Created by Jason on 1/31/15.
//  Copyright (c) 2015 Udacity. All rights reserved.
//

import UIKit
import Foundation


class ImageCache {
    
    var inMemoryCache = NSCache()

    // MARK: - Retreiving images
    
    func imageWithIdentifier(identifier: String?) -> UIImage? {
        
        // If the identifier is nil, or empty, return nil
        if identifier == nil || identifier! == "" {
            return nil
        }
        
        let path = pathForIdentifier(identifier!)
        
        // First try the memory cache
        if let image = inMemoryCache.objectForKey(path) as? UIImage {
            return image
        }
        
        // Next Try the hard drive
        if let data = NSData(contentsOfFile: path) {
            return UIImage(data: data)
        }
        return nil
    }
    
    // MARK: - Saving images
    
    
    func storeImage(image: UIImage?, withIdentifier identifier: String?) {
        if let id = identifier {
            let path = pathForIdentifier(id)
            if let goodImage = image {
                // Otherwise, keep the image in memory
                inMemoryCache.setObject(goodImage, forKey: path)
                let data = UIImagePNGRepresentation(goodImage)!
                data.writeToFile(path, atomically: true)
            } else {
                inMemoryCache.removeObjectForKey(path)
                do {
                    try NSFileManager.defaultManager().removeItemAtPath(path)
                    
                } catch _ {}
                
                return
            }
        } else {
            return
        }

    }

    // MARK: - Helper

    func pathForIdentifier(identifier: String) -> String {
        let documentsDirectoryURL: NSURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        let fullURL = documentsDirectoryURL.URLByAppendingPathComponent(identifier)
        return fullURL.path!
    }
    
    
}