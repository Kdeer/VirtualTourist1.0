//
//  TestViewController.swift
//  GesturePin
//
//  Created by Xiaochao Luo on 2016-05-12.
//  Copyright © 2016 Xiaochao Luo. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class CollectionViewController: UIViewController{
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var editingButton: UIBarButtonItem!
    @IBOutlet weak var TeamStack: UIStackView!
    @IBOutlet weak var freshButton: UIBarButtonItem!
    
    var destinyNumber: Int = 1
    var destinyCellNumber: [Int] = []
    var simuDestinyCellNumber: [Int] = []
    var bunchOfId: [String] = []
    var pinPoint: Pin!
    var pinPoint1 = [ImageInfo]()
    var pinTitle : String? = nil
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let mapSpan = MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
        let mapCenter = CLLocationCoordinate2DMake((pinPoint?.latitude.doubleValue)!, (pinPoint?.longitude.doubleValue)!)
        let region = MKCoordinateRegion(center: mapCenter, span: mapSpan)
        mapView.setRegion(region, animated: true)
        let annotation = MKPointAnnotation()
        annotation.coordinate = mapCenter
        annotation.title = pinTitle
        mapView.addAnnotation(annotation)
        let yourAnnotationAtIndex = 0
        mapView.selectAnnotation(mapView.annotations[yourAnnotationAtIndex], animated: true)
        
        if pinPoint.imageinfos.isEmpty {
            self.getMeImages()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowLocation"  {
            let LocationTableVC: LocationTableViewController = segue.destination as! LocationTableViewController
        }
    }
    
    //mark: updateRefreshButton function
    var pageNumber: Int = 0
    
    func updatedRefreshPage(){
        for i in 0...pinPoint.imageinfos.count-1 {
            
            let path = pathForIdentifier(pinPoint.imageinfos[i].id)
            do {
                try FileManager.default.removeItem(atPath: path)
            }catch _{}
        }
        var imageCollection = pinPoint.imageinfos[0...pinPoint.imageinfos.count-1]
        for i in 0...pinPoint.imageinfos.count-1 {
            imageCollection[i].pinPoint = nil
            sharedContext.delete(imageCollection[i])
            saveContext()
        }
        getMeImages()
        collectionView.reloadData()
    }
    
    //mark: FreshButton Action
    @IBAction func FreshButton(_ sender: AnyObject) {
        updatedRefreshPage()
    }
    
    @IBAction func Editing(_ sender: AnyObject) {
        
        if editingButton.title == "Edit" {
            editingButton.title = "Done"
            for item in collectionView!.visibleCells as![CollectionViewCell] {
                let indexPath : IndexPath = self.collectionView!.indexPath(for: item as CollectionViewCell)!
                let cell = collectionView.cellForItem(at: indexPath) as! CollectionViewCell
                cell.imageView.alpha = 0.5
            }
            
        }else {
            
            self.editingButton.title = "Edit"
            for item in self.collectionView!.visibleCells as![CollectionViewCell] {
                let indexPath : IndexPath = collectionView!.indexPath(for: item as CollectionViewCell)!
                let cell = collectionView.cellForItem(at: indexPath) as! CollectionViewCell
                cell.imageView.alpha = 1
            }
            destinyCellNumber.removeAll()
            simuDestinyCellNumber.removeAll()
            if pinPoint1.count > 0 {
                for i in 0...pinPoint1.count-1 {
                    let path = pathForIdentifier(bunchOfId[i])
                    do {
                        try FileManager.default.removeItem(atPath: path)
                    } catch _ {}
                    sharedContext.delete(pinPoint1[i])
                    saveContext()
                }
            }
            if self.pinPoint.imageinfos.isEmpty {
                getMeImages()
            }
            bunchOfId.removeAll()
            pinPoint1.removeAll()
        collectionView!.reloadData()
        }
    }
    
    @IBAction func ScatterView(_ sender: AnyObject) {
        editingButton.isEnabled = true
        destinyNumber = 1
        collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: UICollectionViewScrollPosition.top, animated: false)
        collectionView.reloadData()
    }
    
    @IBAction func OneView(_ sender: AnyObject) {
        editingButton.isEnabled = false
        destinyNumber = 0
        collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: UICollectionViewScrollPosition.top, animated: false)
        collectionView.reloadData()
    }
    
    
    override var prefersStatusBarHidden : Bool {
        return false
    }
    
    lazy var sharedContext: NSManagedObjectContext =  {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    func saveContext() {
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    func unDeletePhoto(_ sender: UIButton) {
        
        let i : Int = (sender.layer.value(forKey: "index")) as! Int
        self.destinyCellNumber = self.simuDestinyCellNumber
        for m in 0...destinyCellNumber.count - 1 {
            if i == destinyCellNumber[m]{
                bunchOfId.remove(at: m)
                simuDestinyCellNumber.remove(at: m)
                self.pinPoint1.remove(at: m)
            }
        }
    }
    
    func pathForIdentifier(_ identifier: String) -> String {
        let documentsDirectoryURL: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fullURL = documentsDirectoryURL.appendingPathComponent(identifier)
        return fullURL.path
    }
}
