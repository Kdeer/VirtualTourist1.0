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
    var pinPoint : Pin! = nil
    var placemark: MKPlacemark!
    
    @IBOutlet weak var informationButton: UIBarButtonItem!
    
    @IBOutlet weak var NavigationBar: UINavigationItem!
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
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        view.canShowCallout = true

        if control == view.leftCalloutAccessoryView {
            self.latitude = view.annotation!.coordinate.latitude
            self.longitude = view.annotation!.coordinate.longitude

            self.performSegueWithIdentifier("ShowImage", sender: self)
        }else if control == view.rightCalloutAccessoryView {
            
            for r in 0...self.pinPoints.count-1 {
                
                if self.IRound(Double(self.pinPoints[r].latitude)) == self.IRound(view.annotation!.coordinate.latitude) && self.IRound(Double(self.pinPoints[r].longitude)) == self.IRound(view.annotation!.coordinate.longitude) {
                    self.sharedContext.deleteObject(pinPoints[r])
                    self.saveContext()
                    pinPoints.removeAtIndex(r)
                }
            }
            myMap.removeAnnotation(view.annotation!)
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
//                if self.pinPoints[r].latitude == self.latitude && self.pinPoints[r].longitude == self.longitude
                {
                    controller.pinPoint = self.pinPoints[r]
        }
            }
        }else if segue.identifier == "PassData" {
            let controller: CollectionViewController = segue.destinationViewController as! CollectionViewController
            controller.latitude = self.latitude
            controller.longitude = self.longitude
            controller.pinPoint = self.pinPoint
        }else if segue.identifier == "ShowLocation"  {
            let LocationTableVC: LocationTableViewController = segue.destinationViewController as! LocationTableViewController
            
        }
    
    
    
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        appDelegate.imageList.removeAll()
    
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        saveMapRegion()
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
            
//            let region = MKCoordinateRegionMakeWithDistance(newAnotation.coordinate, 1000, 1000)
//            self.myMap.setRegion(region, animated: true)
        
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        let RunImage = UIImage(named: "run")
        let RunButton = UIButton(type: .Custom)
        RunButton.frame = CGRectMake(0, 0, 50, 50)
        RunButton.setImage(RunImage, forState: .Normal)
        
        let DeleteImage = UIImage(named: "close-icon")
        let DeleteButton = UIButton(type: .Custom)
        DeleteButton.frame = CGRectMake(0, 0, 35, 35)
        DeleteButton.setImage(DeleteImage, forState: .Normal)
        
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.animatesDrop = true
            pinView?.canShowCallout = true
            pinView!.pinTintColor = .blueColor()
            pinView!.rightCalloutAccessoryView = DeleteButton
            pinView!.leftCalloutAccessoryView = RunButton
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
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
