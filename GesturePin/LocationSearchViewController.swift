//
//  LocationSearchViewController.swift
//  GesturePin
//
//  Created by Xiaochao Luo on 2016-05-25.
//  Copyright © 2016 Xiaochao Luo. All rights reserved.
//

import Foundation
import UIKit
import MapKit

protocol GetLocation {
    func generateLocation(controller: LocationSearchViewController, placemark: MKPlacemark)
}

class LocationSearchViewController: UIViewController, UISearchResultsUpdating {
    
    @IBOutlet weak var NavigationBar: UINavigationBar!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    //eliminate the bug
    deinit {
        self.resultSearchController?.view.removeFromSuperview()
    }
    
    var resultSearchController : UISearchController!
    var matchingItems: [MKMapItem] = []
    var delegate: GetLocation?
    
    
    @IBAction func Return(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resultSearchController = UISearchController(searchResultsController: nil)
        resultSearchController.searchResultsUpdater = self
        resultSearchController.dimsBackgroundDuringPresentation = false
        resultSearchController.searchBar.sizeToFit()

        tableView.tableHeaderView = self.resultSearchController.searchBar
        tableView.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        guard let searchBarText = searchController.searchBar.text else {
            print("no map view")
            return
        }
        
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchBarText
        let search = MKLocalSearch(request: request)
        
        search.startWithCompletionHandler{ response, _ in
            guard let response = response else {
                return
            }
            self.matchingItems = response.mapItems
            self.tableView.reloadData()
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}

extension LocationSearchViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")!
        let selectedItem = matchingItems[indexPath.row].placemark
        cell.textLabel?.text = selectedItem.name
        cell.detailTextLabel?.text = parseAddress(selectedItem)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedItem = matchingItems[indexPath.row].placemark
        print(selectedItem)

        self.delegate?.generateLocation(self, placemark: selectedItem)
        resultSearchController.active = false
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
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