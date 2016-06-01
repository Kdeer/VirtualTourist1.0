//
//  TestForSearch.swift
//  GesturePin
//
//  Created by Xiaochao Luo on 2016-05-22.
//  Copyright © 2016 Xiaochao Luo. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import MapKit

class TestForSearch: UIViewController, UITableViewDataSource,UITableViewDelegate, UISearchResultsUpdating, MKMapViewDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    let appleProducts = ["Mac","iPhone","Apple Watch","iPad"]
    var filteredAppleProducts = [String]()
    var resultSearchController : UISearchController!
    var pinPoints = [Pin]()
    var locationTitles = [String]()
    var placemark: MKPlacemark!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        pinPoints = fetchAllPins()
        
//        for i in 0...pinPoints.count-1 {
//            self.locationTitles.append(pinPoints[i].title!)
//        }
//        
//        print(locationTitles)
        
        
        self.resultSearchController = UISearchController(searchResultsController: nil)
        self.resultSearchController.searchResultsUpdater = self
        self.resultSearchController.dimsBackgroundDuringPresentation = false
        self.resultSearchController.searchBar.sizeToFit()
        
        tableView.tableHeaderView = self.resultSearchController.searchBar
        
        self.tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if (self.resultSearchController.active)
        {
            return self.filteredAppleProducts.count}
        else
        {
            return appleProducts.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell")!
        
        if (self.resultSearchController.active)
        {
            cell.textLabel?.text = self.filteredAppleProducts[indexPath.row]
            
            return cell
        }
        else
        {
            cell.textLabel?.text = self.appleProducts[indexPath.row]
            
            return cell
        }
    }
    
    
    
    func updateSearchResultsForSearchController(searchController: UISearchController)
    {
        self.filteredAppleProducts.removeAll(keepCapacity: false)
        
        let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchController.searchBar.text!)
        let array = (self.appleProducts as NSArray).filteredArrayUsingPredicate(searchPredicate)
        self.filteredAppleProducts = array as! [String]
        
        self.tableView.reloadData()
    }
    
    @IBAction func GoSearch(sender: AnyObject) {
        searchAdvance{(success, error) in
            
            
            
        }
    }
    
    
    func searchAdvance(completionHandlerForSearch:(success: Bool, error: NSError?)-> Void) {
        
        func sendError(error: String){
            let userInfo = [NSLocalizedDescriptionKey: error]
            
            completionHandlerForSearch(success: false, error: NSError(domain: "Search Location Function", code: 1, userInfo: userInfo))
        }
        
        guard self.resultSearchController.searchBar.text != "" else{
            performUIUpdatesOnMain(){
                let alertController = UIAlertController(title: "Error", message: "The Search Phrase is Empty", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
            }
            sendError("the text field is empty")
            return
        }
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString( self.resultSearchController.searchBar.text!) {(placemarks,error) -> Void in
            
            guard error == nil else {
                performUIUpdatesOnMain(){
                    let alertController = UIAlertController(title: "Error", message: "Cannot Locate This Place", preferredStyle: UIAlertControllerStyle.Alert)
                    alertController.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alertController, animated: true, completion: nil)
                    
                }
                sendError("There is an error")
                return
            }
            
            guard placemarks!.count > 0 else {
                
                dispatch_async(dispatch_get_main_queue(),{
                    let alertController = UIAlertController(title: "Error", message: "Cannot Locate The Place", preferredStyle: UIAlertControllerStyle.Alert)
                    alertController.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alertController, animated: true, completion: nil)
                })
                sendError("Cannot locate the place")
                return
            }
            
            performUIUpdatesOnMain({
                self.placemark = MKPlacemark(placemark: placemarks![0])
                self.mapView.addAnnotation(self.placemark)
                let region = MKCoordinateRegionMakeWithDistance(self.placemark.coordinate, 100000, 100000)
                self.mapView.setRegion(region, animated: true)
                completionHandlerForSearch(success: true, error: error)
            })
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
}