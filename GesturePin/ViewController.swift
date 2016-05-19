//
//  ViewController.swift
//  GesturePin
//
//  Created by Xiaochao Luo on 2016-05-09.
//  Copyright © 2016 Xiaochao Luo. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class ViewController: UIViewController, MKMapViewDelegate {
    
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var pinPoints = [Pin]()
    var placemark: MKPlacemark!
    
    @IBOutlet weak var myMap: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myMap.delegate = self
        pinPoints = fetchAllPins()
//        restoreMapRegion(false)

        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.action(_:)))
        longPress.minimumPressDuration = 0.8
        myMap.addGestureRecognizer(longPress)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let annotationsToRemove = myMap.annotations.filter{ $0 !== myMap.userLocation}
        myMap.removeAnnotations(annotationsToRemove)
        
        
        for locationAnyObject in pinPoints {
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2DMake(locationAnyObject.latitude.doubleValue, locationAnyObject.longitude.doubleValue)
            annotation.title = locationAnyObject.title
            myMap.addAnnotation(annotation)
        }



    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.animatesDrop = true
            pinView?.canShowCallout = true
            pinView!.pinTintColor = .blueColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        view.canShowCallout = true

        if control == view.rightCalloutAccessoryView {

                    let controller = storyboard!.instantiateViewControllerWithIdentifier("CollectionViewController") as! CollectionViewController
                    controller.latitude = view.annotation!.coordinate.latitude
                    controller.longitude = view.annotation!.coordinate.longitude
            
                    for r in 0...self.pinPoints.count-1
                    {
                        if self.IRound(Double(self.pinPoints[r].latitude)) == self.IRound(view.annotation!.coordinate.latitude) && self.IRound(Double(self.pinPoints[r].longitude)) == self.IRound(view.annotation!.coordinate.longitude)
                        {
                            controller.pinPoint = self.pinPoints[r]
            
            
                        }
            }
            
                    self.presentViewController(controller, animated: true,completion: nil)
                    
        }
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.imageList.removeAll()
    
//        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//        appDelegate.imageList.removeAll()
//        let controller = storyboard!.instantiateViewControllerWithIdentifier("CollectionViewController") as! CollectionViewController
//        controller.latitude = view.annotation!.coordinate.latitude
//        controller.longitude = view.annotation!.coordinate.longitude
////        controller.pinPoint = self.pinPoints[0]
//        
//        performUIUpdatesOnMain(){
//        for r in 0...self.pinPoints.count-1
//        {
//            if self.IRound(Double(self.pinPoints[r].latitude)) == self.IRound(view.annotation!.coordinate.latitude) && self.IRound(Double(self.pinPoints[r].longitude)) == self.IRound(view.annotation!.coordinate.longitude)
//            {
//                controller.pinPoint = self.pinPoints[r]
//                
//            
//            }else {
//                print("we are going to load new things")
//            }
//        }
//        
//        self.presentViewController(controller, animated: true,completion: nil)
//        }
    }
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        saveMapRegion()
    }
    
    func action(gestureRecognizer:UIGestureRecognizer) {
        
        if gestureRecognizer.state == UIGestureRecognizerState.Began {
            let touchPoint = gestureRecognizer.locationInView(myMap)
            let newCoordinates = myMap.convertPoint(touchPoint, toCoordinateFromView: myMap)
            
            
            CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: newCoordinates.latitude, longitude: newCoordinates.longitude), completionHandler: {(placemarks, error) -> Void in
                if error != nil {
                    print("Reverse geocoder failed with error" + error!.localizedDescription)
                    return
                }
                
                if placemarks!.count > 0 {
                    // not all places have thoroughfare & subThoroughfare so validate those values
                    self.placemark = MKPlacemark(placemark: placemarks![0])
                    self.myMap.addAnnotation(self.placemark)
                    
                    let dictionary: [String: AnyObject] = [
                        "latitude" : newCoordinates.latitude,
                        "longitude" : newCoordinates.longitude,
                        "title" : self.placemark.title!
                    ]
                    
                    let pin = Pin(dictionary: dictionary, context: self.sharedContext)
                    
                    self.pinPoints.append(pin)
                    self.saveContext()
                    let controller = self.storyboard!.instantiateViewControllerWithIdentifier("CollectionViewController") as! CollectionViewController
                    controller.pinPoint = pin
                    controller.latitude = newCoordinates.latitude
                    controller.longitude = newCoordinates.longitude
                    
                    
                    self.presentViewController(controller, animated: true, completion: nil)
                }
            })
        }
            
//            let region = MKCoordinateRegionMakeWithDistance(newAnotation.coordinate, 1000, 1000)
//            self.myMap.setRegion(region, animated: true)
        
    }
    
    func fetchAllPins() -> [Pin] {
        
        // Create the Fetch Request
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        
        // Execute the Fetch Request
        do {
            return try sharedContext.executeFetchRequest(fetchRequest) as! [Pin]
        } catch  let error as NSError {
            print("Error in fetchAllActors(): \(error)")
            return [Pin]()
        }
    }
    
    lazy var sharedContext: NSManagedObjectContext =  {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    func saveContext() {
        CoreDataStackManager.sharedInstance().saveContext()
    }
    

    
    func IRound(number: Double) -> Double{
        
        var number = number
        number = Double(round(number*100000000)/100000000)
        
        
        return number
    }
    
    
    var filePath : String {
        let manager = NSFileManager.defaultManager()
        let url = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first! as NSURL
        return url.URLByAppendingPathComponent("mapRegionArchive").path!
    }
    
    func saveMapRegion() {
        
        // Place the "center" and "span" of the map into a dictionary
        // The "span" is the width and height of the map in degrees.
        // It represents the zoom level of the map.
        
        let dictionary = [
            "latitude" : myMap.region.center.latitude,
            "longitude" : myMap.region.center.longitude,
            "latitudeDelta" : myMap.region.span.latitudeDelta,
            "longitudeDelta" : myMap.region.span.longitudeDelta
        ]
        
        // Archive the dictionary into the filePath
        NSKeyedArchiver.archiveRootObject(dictionary, toFile: filePath)
    }
    
    func restoreMapRegion(animated: Bool) {
        
        // if we can unarchive a dictionary, we will use it to set the map back to its
        // previous center and span
        if let regionDictionary = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as? [String : AnyObject] {
            
            let longitude = regionDictionary["longitude"] as! CLLocationDegrees
            let latitude = regionDictionary["latitude"] as! CLLocationDegrees
            let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            let longitudeDelta = regionDictionary["latitudeDelta"] as! CLLocationDegrees
            let latitudeDelta = regionDictionary["longitudeDelta"] as! CLLocationDegrees
            let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
            
            let savedRegion = MKCoordinateRegion(center: center, span: span)
            
            print("lat: \(latitude), lon: \(longitude), latD: \(latitudeDelta), lonD: \(longitudeDelta)")
            
            myMap.setRegion(savedRegion, animated: animated)
        }
    }
    
    
    
    
    
    
    
    
    
    //    lazy var fetchedResultsController: NSFetchedResultsController = {
    //        let fetchRequest = NSFetchRequest(entityName: "Pin")
    //        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: true)]
    //        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext,sectionNameKeyPath: nil, cacheName: nil)
    //        print("haha")
    //        return fetchedResultsController
    //        
    //    }()
    

    

}

//extension String {
//    func toDouble() -> Double? {
//        return NSNumberFormatter().numberFromString(self)?.doubleValue
//    }
//}
