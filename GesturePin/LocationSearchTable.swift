//
//  TestVC2.swift
//  GesturePin
//
//  Created by Xiaochao Luo on 2016-05-17.
//  Copyright © 2016 Xiaochao Luo. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class LocationSearchTable: UITableViewController {
    
    //Need this to stash search results for easy access
    var matchingItems: [MKMapItem] = []
    
    //This is a handle to the map from TestVC1 screen.
    var mapView: MKMapView? = nil
    
    var handleMapSearchDelegate: HandleMapSearch? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    //This code transfer the address to postal adress
    func parseAddress(selectedItem: MKPlacemark) -> String {
        
        let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " " : ""
        let comma = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) && (selectedItem.subAdministrativeArea != nil || selectedItem.subAdministrativeArea != nil) ? "," : ""
        let secondSpace = (selectedItem.subAdministrativeArea != nil && selectedItem.administrativeArea != nil) ? " " : ""
        let addressLine = String(
            
        format: "%@%@%@%@%@%@%@",
        selectedItem.subThoroughfare ?? "",
        firstSpace,
        selectedItem.thoroughfare ?? "",
        comma,
        selectedItem.locality ?? "",
        secondSpace,
        
        selectedItem.administrativeArea ?? ""
        )
        return addressLine
    }
    
 
}


extension LocationSearchTable: UISearchResultsUpdating{
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        guard let mapView = mapView,
            let searchBarText = searchController.searchBar.text else{
                return
        }
    
        // A search request is comprised of a search string, and a map region that provides location context. The search string comes from the search bar text, and the map region comes from the mapView.
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchBarText
        request.region = mapView.region
        
        //This performs the actual search on the request object.
        let search = MKLocalSearch(request: request)
        search.startWithCompletionHandler{ response, _ in
            guard let response = response else {
                return
            }
            self.matchingItems = response.mapItems
            self.tableView.reloadData()
        }
    }
}

extension LocationSearchTable {
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")!
        let selectedItem = matchingItems[indexPath.row].placemark
        cell.textLabel?.text = selectedItem.name
        cell.detailTextLabel?.text = parseAddress(selectedItem)
        return cell
    }
}

extension LocationSearchTable {
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedItem = matchingItems[indexPath.row].placemark
        handleMapSearchDelegate?.dropPinZoomIn(selectedItem)
        dismissViewControllerAnimated(true, completion: nil)
    }
}


//UISearchController is made up of three major parts:
//1. searchBar: A search bar comes included with UISearchController.
//2. searchResultsController: This is a custom View Controller you provide to display search results. We use Table View Controller in this tutorial
//3. searchResultsUpdater: This is a delegate that responds to search bar text entry. In this tutorial, the Table View Controller will implement this delegate and updae the table view data source accordingly.
