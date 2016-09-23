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
    
    func taskForImages(_ filePath: String, completionHandler: @escaping (_ imageData: Data?, _ error: NSError?) ->  Void) -> URLSessionTask {
        
        let url = URL(string: filePath)
        
        let request = URLRequest(url: url!)
        let session = URLSession.shared
        
        let task = session.dataTask(with: request, completionHandler: {data, response, downloadError in
            
            if downloadError != nil {
                completionHandler(nil, downloadError as NSError?)
            } else {
                completionHandler(data, nil)
            }
        }) 
        
        task.resume()
        return task
    }
    
    func imagesAtLocation(_ latitude: Double, longitude: Double, completionHandlerForImages: @escaping (_ success: Bool, _ result: AnyObject?, _ error: NSError?) -> Void){
        
        let methodParameters: [String: String?] =
            [
                Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.SearchMethod,
                Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
                Constants.FlickrParameterKeys.BoundingBox: bboxString(latitude, longitude: longitude),
                Constants.FlickrParameterKeys.SafeSearch: Constants.FlickrParameterValues.UseSafeSearch,
                Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL,
                Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
                Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback
        ]
        
        let session = URLSession.shared
        let url = flickrURLFromParameters(methodParameters as [String : AnyObject])
        let request = URLRequest(url: url)
        
        let task = session.dataTask(with: request, completionHandler: {(data, response, error) in
            
            func sendError(_ error: String){
                let userInfo = [NSLocalizedDescriptionKey: error]
                
                completionHandlerForImages(false, nil, NSError(domain: "imagesAtLocation", code: 1, userInfo: userInfo))
            }
            
            guard error == nil else{
                sendError("there is \(error) in queryForLocation")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode , statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            guard let data = data else{
                sendError("There is no data in Query")
                return
            }
            
            let parsedResults: AnyObject!
            do{
                parsedResults = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject!
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
            completionHandlerForImages(true, photosDictionary as AnyObject?, error as NSError?)
            }else {
                completionHandlerForImages(false, nil, error as NSError?)
            }
            
        })
        task.resume()

    }
    
    
    fileprivate func bboxString(_ latitude: Double, longitude: Double) -> String {
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
    
    fileprivate func flickrURLFromParameters(_ parameters: [String:AnyObject]) -> URL {
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.flickr.com"
        components.path = "/services/rest"
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    
    struct Caches {
        static let imageCache = ImageCache()
    }
}
