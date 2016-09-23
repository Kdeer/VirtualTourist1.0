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
    func generateLocation(_ controller: LocationSearchViewController, placemark: MKPlacemark)
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
    
    
    @IBAction func Return(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchBarText = searchController.searchBar.text else {
            print("no map view")
            return
        }
        
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchBarText
        let search = MKLocalSearch(request: request)
        
        search.start{ response, _ in
            guard let response = response else {
                return
            }
            self.matchingItems = response.mapItems
            self.tableView.reloadData()
        }
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
}

extension LocationSearchViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        let selectedItem = matchingItems[(indexPath as NSIndexPath).row].placemark
        cell.textLabel?.text = selectedItem.name
        cell.detailTextLabel?.text = parseAddress(selectedItem)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = matchingItems[(indexPath as NSIndexPath).row].placemark
        print(selectedItem)

        self.delegate?.generateLocation(self, placemark: selectedItem)
        resultSearchController.isActive = false
        self.dismiss(animated: true, completion: nil)
    }
    
    func parseAddress(_ selectedItem: MKPlacemark) -> String {
        
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
