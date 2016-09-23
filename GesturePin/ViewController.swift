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

var globalID: [String] = []

class ViewController: UIViewController, GetLocation{
    
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var pinPoints = [Pin]()
    var pinPoint : Pin! = nil
    var placemark: MKPlacemark!
    var pinTitle: String? = nil
    
    @IBOutlet weak var informationButton: UIBarButtonItem!
    @IBOutlet weak var NavigationBar: UINavigationItem!
    @IBOutlet weak var myMap: MKMapView!
    @IBOutlet weak var goSatellite: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        pinPoints = fetchAllPins()
        restoreMapRegion(false)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.action(_:)))
        longPress.minimumPressDuration = 0.8
        myMap.addGestureRecognizer(longPress)
    }
    
    deinit {
        LocationTableViewController().resultSearchController?.view.removeFromSuperview()
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowImage" {

            let controller: CollectionViewController = segue.destination as! CollectionViewController
            controller.latitude = latitude
            controller.longitude = longitude

            for r in 0...pinPoints.count-1
            {
            if self.IRound(Double(pinPoints[r].latitude)) == IRound(latitude) && IRound(Double(pinPoints[r].longitude)) == IRound(longitude)
                {
                    controller.pinPoint = pinPoints[r]
                    controller.pinTitle = pinTitle
                }
            }
        }else if segue.identifier == "PassData"{
            let controller: CollectionViewController = segue.destination as! CollectionViewController
            controller.latitude = latitude
            controller.longitude = longitude
            controller.pinPoint = pinPoint
            controller.pinTitle = pinTitle
        }else if segue.identifier == "ShowLocation"  {
            let LocationTableVC: LocationTableViewController = segue.destination as! LocationTableViewController
        }else if segue.identifier == "ShowAddress" {
            let controller: LocationSearchViewController = segue.destination as! LocationSearchViewController
            controller.delegate = self
        }
    }
    
    func generateLocation(_ controller: LocationSearchViewController, placemark: MKPlacemark){
        
        self.placemark = placemark
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        
        let dictionary: [String: AnyObject] = [
            "latitude" : placemark.coordinate.latitude as AnyObject,
            "longitude" : placemark.coordinate.longitude as AnyObject,
            "title" : self.placemark.title! as AnyObject
        ]
        pinTitle = self.placemark.title!
        let pin = Pin(dictionary: dictionary, context: self.sharedContext)
        latitude = placemark.coordinate.latitude
        longitude = placemark.coordinate.longitude
        pinPoint = pin
        pinPoints.append(pin)
        saveContext()
        
        myMap.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        myMap.setRegion(region, animated: true)
    }
    
    func action(_ gestureRecognizer:UIGestureRecognizer) {
        
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            let touchPoint = gestureRecognizer.location(in: myMap)
            let newCoordinates = myMap.convert(touchPoint, toCoordinateFrom: myMap)
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
                        "latitude" : newCoordinates.latitude as AnyObject,
                        "longitude" : newCoordinates.longitude as AnyObject,
                        "title" : self.placemark.title! as AnyObject
                    ]
                    self.pinTitle = self.placemark.title!
                    
                    let pin = Pin(dictionary: dictionary, context: self.sharedContext)
                    self.latitude = newCoordinates.latitude
                    self.longitude = newCoordinates.longitude
                    self.pinPoint = pin
                    self.pinPoints.append(pin)
                    self.saveContext()
                    self.performSegue(withIdentifier: "PassData", sender: self)
                }
            })
        }
    }
    
    @IBAction func SearchButtonPressed(_ sender: AnyObject) {
        
        let controller = storyboard!.instantiateViewController(withIdentifier: "LocationSearchViewController") as! LocationSearchViewController
        controller.delegate = self
        
        self.present(controller, animated: false, completion: nil)
        
    }
    
    @IBAction func HugeRefresh(_ sender: AnyObject) {
        
        
        print(pinPoints)
        let alertController = UIAlertController(title: "Alert", message: "Sure to delete all you pins?", preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: "Yes", style: .default){
            (action) in
            
            let annotationsToRemove = self.myMap.annotations.filter{ $0 !== self.myMap.userLocation}
            self.myMap.removeAnnotations(annotationsToRemove)
        
            if self.pinPoints.count > 0 {
                
                for i in 0...self.pinPoints.count - 1 {
                    if self.pinPoints[i].imageinfos.isEmpty {
                        self.sharedContext.delete(self.pinPoints[i])
                    }else {
                    for m in 0...self.pinPoints[i].imageinfos.count-1 {
                        let path = self.pathForIdentifier(self.pinPoints[i].imageinfos[m].id)
                        do {
                            try FileManager.default.removeItem(atPath: path)
                        }catch _{}
                    }
                }
                }
                
                for i in 0...self.pinPoints.count-1 {
                    
                    self.sharedContext.delete(self.pinPoints[i])
                    self.saveContext()
                }

            }else {
                
                for m in 0...self.pinPoints[0].imageinfos.count-1 {
                    let path = self.pathForIdentifier(self.pinPoints[0].imageinfos[m].id)
                    do {
                        try FileManager.default.removeItem(atPath: path)
                    }catch _{}
                }
                
                self.sharedContext.delete(self.pinPoints[0])
                self.saveContext()
            }
                self.pinPoints.removeAll()

//            print(self.pinPoints[0].imageinfos)
        }
        
        alertController.addAction(OKAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)

    }
    
    @IBAction func GoForLocations(_ sender: AnyObject) {
        
        self.performSegue(withIdentifier: "ShowLocation", sender: self)
    }
    
    @IBAction func GoSatellite(_ sender: AnyObject) {
        if myMap.mapType == .satellite {
            myMap.mapType = .standard
            goSatellite.tintColor = nil
        }else {
            myMap.mapType = .satellite
            goSatellite.tintColor = UIColor.blue
        }
        
    }
    
    func fetchAllPins() -> [Pin] {
        
        // Create the Fetch Request
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Pin")
        
        // Execute the Fetch Request
        do {
            return try sharedContext.fetch(fetchRequest) as! [Pin]
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
        let manager = FileManager.default
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first! as URL
        return url.appendingPathComponent("mapRegionArchive").path
    }
    
    func pathForIdentifier(_ identifier: String) -> String {
        let documentsDirectoryURL: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fullURL = documentsDirectoryURL.appendingPathComponent(identifier)
        return fullURL.path
    }
}
