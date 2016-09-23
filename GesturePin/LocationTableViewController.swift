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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        pinPoints = fetchAllPins().reversed()
        print(filteredResults)
    }
    
    override func viewDidLoad() {
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        resultSearchController = UISearchController(searchResultsController: nil)
        resultSearchController.searchResultsUpdater = self
        resultSearchController.hidesNavigationBarDuringPresentation = false
        resultSearchController.dimsBackgroundDuringPresentation = false
        resultSearchController.searchBar.sizeToFit()
        
        tableView.tableHeaderView = resultSearchController.searchBar
        tableView.reloadData()
    }
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        if resultSearchController.isActive {
            return filteredResults.count
        }else {
        
        return pinPoints.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as UITableViewCell!
        let locations = pinPoints[(indexPath as NSIndexPath).row]
        
        if resultSearchController.isActive {
            cell?.textLabel?.text = self.filteredResults[(indexPath as NSIndexPath).row]
            return cell!
        }else {
        
        cell?.textLabel!.text = locations.title!
        titleArray.append((cell?.textLabel!.text!)!)
        return cell!
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
        filteredResults.removeAll(keepingCapacity: false)
            
        let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchController.searchBar.text!)
        let array = (self.titleArray as NSArray).filtered(using: searchPredicate)
        filteredResults = array as! [String]
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if resultSearchController.isActive {
            for i in 0...pinPoints.count - 1 {
                if filteredResults[(indexPath as NSIndexPath).row] == pinPoints[i].title {
                    self.pinPoint = pinPoints[i]
                    self.pinTitle = pinPoints[i].title
                    self.performSegue(withIdentifier: "ShowImage", sender: self)
                }
        }
        }else {
        let locations = pinPoints[(indexPath as NSIndexPath).row]
        print(locations)
        self.pinPoint = locations
        pinTitle = pinPoints[(indexPath as NSIndexPath).row].title
        self.performSegue(withIdentifier: "ShowImage", sender: self)
        }
        
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch (editingStyle) {
        case .delete:
            
            if pinPoints[(indexPath as NSIndexPath).row].imageinfos.count > 0 {
            for m in 0...pinPoints[(indexPath as NSIndexPath).row].imageinfos.count-1{
                let path = self.pathForIdentifier(pinPoints[(indexPath as NSIndexPath).row].imageinfos[m].id)
                do {
                    try FileManager.default.removeItem(atPath: path)
                }catch _{}
            }
            }
            sharedContext.delete(pinPoints[(indexPath as NSIndexPath).row])
            pinPoints.remove(at: (indexPath as NSIndexPath).row)
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
            self.saveContext()
            print(pinPoints)

            
        default:
            break
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowImage" {
            
            let CollectionVC: CollectionViewController = segue.destination as! CollectionViewController
            CollectionVC.latitude = self.latitude
            CollectionVC.longitude = self.longitude
            CollectionVC.pinPoint = self.pinPoint
            CollectionVC.pinTitle = self.pinTitle
            self.dismiss(animated: true, completion: nil)
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
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Pin")
        
        // Execute the Fetch Request
        do {
            return try sharedContext.fetch(fetchRequest) as! [Pin]
        } catch  let error as NSError {
            print("Error in fetchAllActors(): \(error)")
            return [Pin]()
        }
    }
    
    func pathForIdentifier(_ identifier: String) -> String {
        let documentsDirectoryURL: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fullURL = documentsDirectoryURL.appendingPathComponent(identifier)
        return fullURL.path
    }
    
    
    
}
