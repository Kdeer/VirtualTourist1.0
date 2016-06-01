//
//  TestVC1.swift
//  GesturePin
//
//  Created by Xiaochao Luo on 2016-05-17.
//  Copyright © 2016 Xiaochao Luo. All rights reserved.
//

import Foundation
import UIKit
import MapKit


//We need to drop a pin on the map whenever the user taps on a search result. Since the map and table view are in two separate controllers, we'll use a protocol to communicate between the two.
//The table view controller will call this method whenever the user selects a search result.
//This declares a custom protocol named HandleMapSearch. Anything that conforms to this protocol has to implement a method called dropPinZoomIn(_:)
protocol HandleMapSearch {
    func dropPinZoomIn(placemark: MKPlacemark)
}

class TestVC1: UIViewController {
    
    //CLLocationManager variable gives you access to the location manager throughout the scope of the controller
    let locationManager = CLLocationManager()
    
    //This variable has controller-level scope to keep the UISearchController in memory after it;s created.
    var resultSearchController: UISearchController? = nil
    
    var selectedPin: MKPlacemark? = nil
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Delegate methods are used to handle responses asynchoronously
        locationManager.delegate = self
        
        //This is optional, but you might want to override the default accuracy level with an explicit value, like KCLLocationAccuracyBest. Or you could use something less accurate liek KCLLocationAccuracyHundredMeters to conserve battery life.
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        //This triggers the location permission dialog. The user will only see the dialog once
        locationManager.requestWhenInUseAuthorization()
        
        
        //Triggers a one time location request
        locationManager.requestLocation()
        
        //This is the table view controller you set up earlier in the Storybaord. It will also serve as the searchResultsUpdater delegate.
        let locationSearchTable = storyboard!.instantiateViewControllerWithIdentifier("LocationSearchTable") as! LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        navigationItem.titleView = resultSearchController?.searchBar
        
        //This determines whether the Navigation Bar disappears when the search results are shown.
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        
        //Gives a semi-transparent background when the search bar is selected
        resultSearchController?.dimsBackgroundDuringPresentation = true
        
        //This litmits the overlap area to just the view controller's frame instead of the whole Navigation Controller.
        definesPresentationContext = true
        
        
        //This passess along a handle of the mapView from the main VIewController onto the locationSearchTable.
        locationSearchTable.mapView = mapView
        
        //wire up the protocol
        locationSearchTable.handleMapSearchDelegate = self
        
    }
    
    func getDirections(){
        if let selectedPin = selectedPin{
            let mapItem = MKMapItem(placemark: selectedPin)
            let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
            mapItem.openInMapsWithLaunchOptions(launchOptions)
        }
    }
 
}

extension TestVC1: CLLocationManagerDelegate {
    
    //This method gets called when the user responds to the permission dialog. If the user chose Allow, the status becomes CLAuthorizationStatus.AurthorizedWhenInUse. You also trigger another requrstLocation() because the first attempt would have suffered a permission failure.
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse{
            locationManager.requestLocation()
        }
    }
    
    //This gets called when location information comes back. You get an array of locations, but you're only interested in the first item. You don't do anything with it yet, but eventually you will zoom to this location.
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            print(locations)
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)
            print("location: \(location)")
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("error\(error)")
    }
    
}


//This extension implments the dropPinZoomIn() method in order to adopt the HandleMapSearch protocol.
//The incoming placemark is cached in the selectedPin Variable.This willbe useful later when you carete a callout button.
extension TestVC1: HandleMapSearch {
    
    func dropPinZoomIn(placemark: MKPlacemark) {
        selectedPin = placemark
        
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)
    }
    
}

//The last step is to customize the map pin callout with a button that takes you to Apple Maps for driving diretions.
extension TestVC1: MKMapViewDelegate {
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        }
        let reuserID = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuserID) as? MKPinAnnotationView
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuserID)
        pinView?.pinTintColor = UIColor.orangeColor()
        pinView?.canShowCallout = true
        let smallSquare = CGSize(width: 30, height: 30)
        let button = UIButton(frame: CGRect(origin: CGPointZero, size: smallSquare))
        button.setBackgroundImage(UIImage(named: "run"), forState: .Normal)
        button.addTarget(self, action: #selector(TestVC1.getDirections), forControlEvents: .TouchUpInside)
        pinView?.leftCalloutAccessoryView = button
        return pinView
    }
    
}


//    @IBAction func GoT2(sender: AnyObject) {
//        self.goT2.enabled = true
////       let controller = storyboard!.instantiateViewControllerWithIdentifier("TestVC2") as! TestVC2
////
////    self.navigationController!.pushViewController(controller, animated: true)
//
//
//    }

