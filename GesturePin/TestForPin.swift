//
//  CollectionViewController.swift
//  GesturePin
//
//  Created by Xiaochao Luo on 2016-05-09.
//  Copyright © 2016 Xiaochao Luo. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import MapKit


class TestForPin: UIViewController, MKMapViewDelegate{
    
    @IBOutlet weak var mapView: MKMapView!
    
    var annotations : [MKPointAnnotation] = [MKPointAnnotation]()
    var placemark: MKPlacemark!
    
    
    

    
    override func viewDidLoad() {
        mapView.delegate = self
        
        self.mapView.addAnnotations(annotations)
        
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.action(_:)))
        longPress.minimumPressDuration = 0.8
        mapView.addGestureRecognizer(longPress)
    }
    @IBAction func Dismiss(sender: AnyObject) {
        
        
        
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.animatesDrop = true
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .blueColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    func action(gestureRecognizer: UIGestureRecognizer){
        
        if gestureRecognizer.state == UIGestureRecognizerState.Began {
            let touchPoint = gestureRecognizer.locationInView(mapView)
            let newCoordinates = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)

            
            CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: newCoordinates.latitude, longitude: newCoordinates.longitude), completionHandler: {(placemarks, error) -> Void in
                if error != nil {
                    print("Reverse geocoder failed with error" + error!.localizedDescription)
                    return
                }
                
                if placemarks!.count > 0 {
                    // not all places have thoroughfare & subThoroughfare so validate those values
                    self.placemark = MKPlacemark(placemark: placemarks![0])
                    self.mapView.addAnnotation(self.placemark)
                }
            })
        }
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == view.rightCalloutAccessoryView {
        let controller = storyboard!.instantiateViewControllerWithIdentifier("ViewController") as! ViewController
        
        self.presentViewController(controller, animated: true, completion: nil)
        
        }
    }
    
    
    
//    https://farm8.staticflickr.com/7137/26735858680_c2c2842855.jpg
//    /Users/Zack/Library/Developer/CoreSimulator/Devices/4B2D9FAE-8B27-4860-8502-EAA9B0F6E5A5/data/Containers/Data/Application/92CBB8C0-5F6D-4CD8-BA91-DC875964CE0E/Documents/https://farm8.staticflickr.com/7137/26735858680_c2c2842855.jpg
    
    
    
    
    
}