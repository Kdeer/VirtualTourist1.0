//
//  VirtualTouristClient.swift
//  GesturePin
//
//  Created by Xiaochao Luo on 2016-05-09.
//  Copyright © 2016 Xiaochao Luo. All rights reserved.
//

import Foundation



class VirtualTouristClient: NSObject {
    
//    var imageInfos = [ImageInfo]()
    
    func taskForImages(filePath: String, completionHandler: (imageData: NSData?, error: NSError?) ->  Void) -> NSURLSessionTask {
        
        let url = NSURL(string: filePath)
        
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            if downloadError != nil {
                completionHandler(imageData: nil, error: downloadError)
            } else {
                completionHandler(imageData: data, error: nil)
            }
        }
        
        task.resume()
        return task
    }
    
    func imagesAtLocation(latitude: Double, longitude: Double, completionHandlerForImages: (success: Bool, result: AnyObject!, error: NSError?) -> Void){
        
        let methodParameters: [String: String!] =
            [
                Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.SearchMethod,
                Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
                Constants.FlickrParameterKeys.BoundingBox: bboxString(latitude, longitude: longitude),
                Constants.FlickrParameterKeys.SafeSearch: Constants.FlickrParameterValues.UseSafeSearch,
                Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL,
                Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
                Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback
        ]
        
        let session = NSURLSession.sharedSession()
        let url = flickrURLFromParameters(methodParameters)
        let request = NSMutableURLRequest(URL: url)
        
        let task = session.dataTaskWithRequest(request){(data, response, error) in
            
            func sendError(error: String){
                let userInfo = [NSLocalizedDescriptionKey: error]
                
                completionHandlerForImages(success: false, result: nil, error: NSError(domain: "imagesAtLocation", code: 1, userInfo: userInfo))
            }
            
            guard error == nil else{
                sendError("there is \(error) in queryForLocation")
                return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            guard let data = data else{
                sendError("There is no data in Query")
                return
            }
            
            let parsedResults: AnyObject!
            do{
                parsedResults = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            }catch {
                sendError("cannot parse the data")
                return
            }
            
            guard let photosDictionary = parsedResults["photos"] as? [String:AnyObject] else {
                sendError("no photos array in data")
                return
            }
            if (photosDictionary["photo"] as? [[String:AnyObject]]) != nil{
                
//            let imageURLArray = imageInfo.imagesFromResults(photoArray)
            completionHandlerForImages(success: true, result: photosDictionary, error: error)
            }else {
                completionHandlerForImages(success: false, result: nil, error: error)
            }
            
        }
        task.resume()

    }
    
    
    private func bboxString(latitude: Double, longitude: Double) -> String {
        // ensure bbox is bounded by minimum and maximums
//        if let latitude = Double(latitudeTextField.text!), let longitude = Double(longitudeTextField.text!) {
            let minimumLon = max(longitude - 1, -180)
            let minimumLat = max(latitude - 1, -90)
            let maximumLon = min(longitude + 1, 180)
            let maximumLat = min(latitude + 1, 90)
            return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
    }
    
    
    
    
    class func sharedInstance() -> VirtualTouristClient {
        struct Singleton {
            static var sharedInstance = VirtualTouristClient()
        }
        return Singleton.sharedInstance
    }
    
    private func flickrURLFromParameters(parameters: [String:AnyObject]) -> NSURL {
        
        let components = NSURLComponents()
        components.scheme = "https"
        components.host = "api.flickr.com"
        components.path = "/services/rest"
        components.queryItems = [NSURLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = NSURLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.URL!
    }
    
    struct Caches {
        static let imageCache = ImageCache()
    }
}