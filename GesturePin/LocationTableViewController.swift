//
//  LocationTableViewController.swift
//  GesturePin
//
//  Created by Xiaochao Luo on 2016-05-20.
//  Copyright © 2016 Xiaochao Luo. All rights reserved.
//

import Foundation
import UIKit
import CoreData


class LocationTableViewController: UITableViewController {
    
    var pinPoints = [Pin]()
    var pinPointsR = [Pin]()
    var LocationTitles = [LocationTitle]()
    var imageInfos: ImageInfo!
    var pinPoint : Pin! = nil
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        pinPoints = fetchAllPins()
        self.pinPointsR = pinPoints.reverse()
        
        print(pinPoints)
    }
    
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        return pinPoints.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("LocationCell", forIndexPath: indexPath) as UITableViewCell!
        let locations = pinPointsR[indexPath.row]
        
        cell.textLabel!.text = locations.title!
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let locations = pinPointsR[indexPath.row]
        self.pinPoint = locations
        self.performSegueWithIdentifier("ShowImage", sender: self)
        
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowImage" {
            
            let CollectionVC: CollectionViewController = segue.destinationViewController as! CollectionViewController
            CollectionVC.latitude = self.latitude
            CollectionVC.longitude = self.longitude
            CollectionVC.pinPoint = self.pinPoint
            
        }
    }
    
    
    
    
    
    lazy var sharedContext: NSManagedObjectContext =  {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    func saveContext() {
        CoreDataStackManager.sharedInstance().saveContext()
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
    
    
    
}