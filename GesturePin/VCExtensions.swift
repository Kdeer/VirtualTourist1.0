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
    
    func restoreMapRegion(_ animated: Bool) {
        
        if let regionDictionary = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as? [String : AnyObject] {
            
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
    
    func IRound(_ number: Double) -> Double{
        
        var number = number
        number = Double(round(number*100000000)/100000000)
        
        return number
    }
}

extension ViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        view.canShowCallout = true
 
        if control == view.rightCalloutAccessoryView {
            latitude = view.annotation!.coordinate.latitude
            longitude = view.annotation!.coordinate.longitude
            pinTitle = view.annotation!.title!
            self.performSegue(withIdentifier: "ShowImage", sender: self)

        }else if control == view.leftCalloutAccessoryView {
            
            for r in 0...pinPoints.count-1 {
                
                if IRound(Double(pinPoints[r].latitude)) == IRound(view.annotation!.coordinate.latitude) && IRound(Double(pinPoints[r].longitude)) == IRound(view.annotation!.coordinate.longitude) {
                    if !self.pinPoints[r].imageinfos.isEmpty{
                    for m in 0...pinPoints[r].imageinfos.count - 1 {
                        let path = self.pathForIdentifier(self.pinPoints[r].imageinfos[m].id)
                        do {
                            try FileManager.default.removeItem(atPath: path)
                        }catch _{}
                        }
                    }
                    sharedContext.delete(pinPoints[r])
                    pinPoints.remove(at: r)
                    saveContext()
                    
                }
            }
            myMap.removeAnnotation(view.annotation!)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        let RunImage = UIImage(named: "look")
        let RunButton = UIButton(type: .custom)
        RunButton.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        RunButton.setImage(RunImage, for: UIControlState())
        
        let DeleteImage = UIImage(named: "delete")
        let DeleteButton = UIButton(type: .custom)
        DeleteButton.frame = CGRect(x: 0, y: 0, width: 23, height: 23)
        DeleteButton.setImage(DeleteImage, for: UIControlState())
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.animatesDrop = true
            pinView?.canShowCallout = true
            pinView!.pinTintColor = UIColor.blue
            pinView!.rightCalloutAccessoryView = RunButton
            pinView!.leftCalloutAccessoryView = DeleteButton
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        saveMapRegion()
    }
}
