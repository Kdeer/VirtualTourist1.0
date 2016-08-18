//
//  VCExtensions.swift
//  GesturePin
//
//  Created by Xiaochao Luo on 2016-05-25.
//  Copyright © 2016 Xiaochao Luo. All rights reserved.
//

import Foundation
import MapKit



extension ViewController{
    
    func saveMapRegion() {
        
        let dictionary = [
            "latitude" : myMap.region.center.latitude,
            "longitude" : myMap.region.center.longitude,
            "latitudeDelta" : myMap.region.span.latitudeDelta,
            "longitudeDelta" : myMap.region.span.longitudeDelta
        ]
        
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
    
    func IRound(number: Double) -> Double{
        
        var number = number
        number = Double(round(number*100000000)/100000000)
        
        return number
    }
}

extension ViewController: MKMapViewDelegate {
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        view.canShowCallout = true
 
        if control == view.rightCalloutAccessoryView {
            latitude = view.annotation!.coordinate.latitude
            longitude = view.annotation!.coordinate.longitude
            pinTitle = view.annotation!.title!
            self.performSegueWithIdentifier("ShowImage", sender: self)

        }else if control == view.leftCalloutAccessoryView {
            
            for r in 0...pinPoints.count-1 {
                
                if IRound(Double(pinPoints[r].latitude)) == IRound(view.annotation!.coordinate.latitude) && IRound(Double(pinPoints[r].longitude)) == IRound(view.annotation!.coordinate.longitude) {
                    if !self.pinPoints[r].imageinfos.isEmpty{
                    for m in 0...pinPoints[r].imageinfos.count - 1 {
                        let path = self.pathForIdentifier(self.pinPoints[r].imageinfos[m].id)
                        do {
                            try NSFileManager.defaultManager().removeItemAtPath(path)
                        }catch _{}
                        }
                    }
                    sharedContext.deleteObject(pinPoints[r])
                    pinPoints.removeAtIndex(r)
                    saveContext()
                    
                }
            }
            myMap.removeAnnotation(view.annotation!)
        }
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {

        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        let RunImage = UIImage(named: "look")
        let RunButton = UIButton(type: .Custom)
        RunButton.frame = CGRectMake(0, 0, 50, 50)
        RunButton.setImage(RunImage, forState: .Normal)
        
        let DeleteImage = UIImage(named: "delete")
        let DeleteButton = UIButton(type: .Custom)
        DeleteButton.frame = CGRectMake(0, 0, 23, 23)
        DeleteButton.setImage(DeleteImage, forState: .Normal)
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.animatesDrop = true
            pinView?.canShowCallout = true
            pinView!.pinTintColor = .blueColor()
            pinView!.rightCalloutAccessoryView = RunButton
            pinView!.leftCalloutAccessoryView = DeleteButton
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        saveMapRegion()
    }
}