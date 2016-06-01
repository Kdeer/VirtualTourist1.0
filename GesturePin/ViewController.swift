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

class ViewController: UIViewController, GetLocation{
    
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var pinPoints = [Pin]()
    var pinPoint : Pin! = nil
    var placemark: MKPlacemark!
    var locationManager = CLLocationManager()
    
    
    @IBOutlet weak var informationButton: UIBarButtonItem!
    @IBOutlet weak var NavigationBar: UINavigationItem!
    @IBOutlet weak var myMap: MKMapView!
    @IBOutlet weak var goSatellite: UIBarButtonItem!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pinPoints = fetchAllPins()
//        restoreMapRegion(false)
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowImage" {

            let controller: CollectionViewController = segue.destinationViewController as! CollectionViewController
            controller.latitude = self.latitude
            controller.longitude = self.longitude
            for r in 0...self.pinPoints.count-1
            {
            if self.IRound(Double(self.pinPoints[r].latitude)) == self.IRound(self.latitude) && self.IRound(Double(self.pinPoints[r].longitude)) == self.IRound(self.longitude)
                {
                    controller.pinPoint = self.pinPoints[r]
                }
            }
        }else if segue.identifier == "PassData"{
            let controller: CollectionViewController = segue.destinationViewController as! CollectionViewController
            controller.latitude = self.latitude
            controller.longitude = self.longitude
            controller.pinPoint = self.pinPoint
        }else if segue.identifier == "ShowLocation"  {
            let LocationTableVC: LocationTableViewController = segue.destinationViewController as! LocationTableViewController
        }else if segue.identifier == "ShowAddress" {
            let controller: LocationSearchViewController = segue.destinationViewController as! LocationSearchViewController
            controller.delegate = self
        }
    }
    
    func generateLocation(controller: LocationSearchViewController, placemark: MKPlacemark){
        
        self.placemark = placemark
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        
        let dictionary: [String: AnyObject] = [
            "latitude" : placemark.coordinate.latitude,
            "longitude" : placemark.coordinate.longitude,
            "title" : self.placemark.title!
        ]
        
        let pin = Pin(dictionary: dictionary, context: self.sharedContext)
        self.latitude = placemark.coordinate.latitude
        self.longitude = placemark.coordinate.longitude
        self.pinPoint = pin
        self.pinPoints.append(pin)
        self.saveContext()
        
        
        myMap.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        myMap.setRegion(region, animated: true)
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
                    self.latitude = newCoordinates.latitude
                    self.longitude = newCoordinates.longitude
                    self.pinPoint = pin
                    self.pinPoints.append(pin)
                    self.saveContext()
                    self.performSegueWithIdentifier("PassData", sender: self)
                }
            })
        }
    }
    
    @IBAction func SearchButtonPressed(sender: AnyObject) {
        
        let controller = storyboard!.instantiateViewControllerWithIdentifier("LocationSearchViewController") as! LocationSearchViewController
        controller.delegate = self
        
        presentViewController(controller, animated: true, completion: nil)
        
    }
    
    
    @IBAction func HugeRefresh(sender: AnyObject) {
        
        let annotationsToRemove = myMap.annotations.filter{ $0 !== myMap.userLocation}
        myMap.removeAnnotations(annotationsToRemove)
        
        if pinPoints.count > 0 {
            for i in 0...pinPoints.count-1 {
                
                self.sharedContext.deleteObject(pinPoints[i])
                self.saveContext()
            }
            pinPoints.removeAll()
        }
    }
    
    @IBAction func GoForLocations(sender: AnyObject) {
        
        self.performSegueWithIdentifier("ShowLocation", sender: self)
    }
    
    @IBAction func GoSatellite(sender: AnyObject) {
        if self.myMap.mapType == .Satellite {
            self.myMap.mapType = .Standard
            goSatellite.tintColor = nil
        }else {
            self.myMap.mapType = .Satellite
            goSatellite.tintColor = UIColor.blueColor()
        }
        
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
    
    var filePath : String {
        let manager = NSFileManager.defaultManager()
        let url = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first! as NSURL
        return url.URLByAppendingPathComponent("mapRegionArchive").path!
    }

}

//extension String {
//    func toDouble() -> Double? {
//        return NSNumberFormatter().numberFromString(self)?.doubleValue
//    }
//}
