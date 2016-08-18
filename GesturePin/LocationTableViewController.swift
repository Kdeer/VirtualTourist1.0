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


class LocationTableViewController: UITableViewController, UISearchResultsUpdating {
    
    var pinPoints = [Pin]()
    var LocationTitles = [LocationTitle]()
    var pinPoint : Pin! = nil
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var resultSearchController: UISearchController!
    var filteredResults = [String]()
    var titleArray : [String] = []
    var pinTitle : String? = nil
    
    deinit {
        self.resultSearchController?.view.removeFromSuperview()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        pinPoints = fetchAllPins().reverse()
        print(filteredResults)
    }
    
    override func viewDidLoad() {
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        resultSearchController = UISearchController(searchResultsController: nil)
        resultSearchController.searchResultsUpdater = self
        resultSearchController.hidesNavigationBarDuringPresentation = false
        resultSearchController.dimsBackgroundDuringPresentation = false
        resultSearchController.searchBar.sizeToFit()
        
        tableView.tableHeaderView = resultSearchController.searchBar
        tableView.reloadData()
    }
    
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        if resultSearchController.active {
            return filteredResults.count
        }else {
        
        return pinPoints.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("LocationCell", forIndexPath: indexPath) as UITableViewCell!
        let locations = pinPoints[indexPath.row]
        
        if resultSearchController.active {
            cell.textLabel?.text = self.filteredResults[indexPath.row]
            return cell
        }else {
        
        cell.textLabel!.text = locations.title!
        titleArray.append(cell.textLabel!.text!)
        return cell
        }
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        filteredResults.removeAll(keepCapacity: false)
            
        let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchController.searchBar.text!)
        let array = (self.titleArray as NSArray).filteredArrayUsingPredicate(searchPredicate)
        filteredResults = array as! [String]
        tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if resultSearchController.active {
            for i in 0...pinPoints.count - 1 {
                if filteredResults[indexPath.row] == pinPoints[i].title {
                    self.pinPoint = pinPoints[i]
                    self.pinTitle = pinPoints[i].title
                    self.performSegueWithIdentifier("ShowImage", sender: self)
                }
        }
        }else {
        let locations = pinPoints[indexPath.row]
        print(locations)
        self.pinPoint = locations
        pinTitle = pinPoints[indexPath.row].title
        self.performSegueWithIdentifier("ShowImage", sender: self)
        }
        
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        switch (editingStyle) {
        case .Delete:
            
            if pinPoints[indexPath.row].imageinfos.count > 0 {
            for m in 0...pinPoints[indexPath.row].imageinfos.count-1{
                let path = self.pathForIdentifier(pinPoints[indexPath.row].imageinfos[m].id)
                do {
                    try NSFileManager.defaultManager().removeItemAtPath(path)
                }catch _{}
            }
            }
            sharedContext.deleteObject(pinPoints[indexPath.row])
            pinPoints.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            self.saveContext()
            print(pinPoints)

            
        default:
            break
        }
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowImage" {
            
            let CollectionVC: CollectionViewController = segue.destinationViewController as! CollectionViewController
            CollectionVC.latitude = self.latitude
            CollectionVC.longitude = self.longitude
            CollectionVC.pinPoint = self.pinPoint
            CollectionVC.pinTitle = self.pinTitle
            self.dismissViewControllerAnimated(true, completion: nil)
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
    
    func pathForIdentifier(identifier: String) -> String {
        let documentsDirectoryURL: NSURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        let fullURL = documentsDirectoryURL.URLByAppendingPathComponent(identifier)
        return fullURL.path!
    }
    
    
    
}