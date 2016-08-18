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
    
    override func viewWillAppear(animated: Bool) {
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowLocation"  {
            let LocationTableVC: LocationTableViewController = segue.destinationViewController as! LocationTableViewController
        }
    }
    
    //mark: updateRefreshButton function
    var pageNumber: Int = 0
    
    func updatedRefreshPage(){
        for i in 0...pinPoint.imageinfos.count-1 {
            
            let path = pathForIdentifier(pinPoint.imageinfos[i].id)
            do {
                try NSFileManager.defaultManager().removeItemAtPath(path)
            }catch _{}
        }
        var imageCollection = pinPoint.imageinfos[0...pinPoint.imageinfos.count-1]
        for i in 0...pinPoint.imageinfos.count-1 {
            imageCollection[i].pinPoint = nil
            sharedContext.deleteObject(imageCollection[i])
            saveContext()
        }
        getMeImages()
        collectionView.reloadData()
    }
    
    //mark: FreshButton Action
    @IBAction func FreshButton(sender: AnyObject) {
        updatedRefreshPage()
    }
    
    @IBAction func Editing(sender: AnyObject) {
        
        if editingButton.title == "Edit" {
            editingButton.title = "Done"
            for item in collectionView!.visibleCells() as![CollectionViewCell] {
                let indexPath : NSIndexPath = self.collectionView!.indexPathForCell(item as CollectionViewCell)!
                let cell = collectionView.cellForItemAtIndexPath(indexPath) as! CollectionViewCell
                cell.imageView.alpha = 0.5
            }
            
        }else {
            
            self.editingButton.title = "Edit"
            for item in self.collectionView!.visibleCells() as![CollectionViewCell] {
                let indexPath : NSIndexPath = collectionView!.indexPathForCell(item as CollectionViewCell)!
                let cell = collectionView.cellForItemAtIndexPath(indexPath) as! CollectionViewCell
                cell.imageView.alpha = 1
            }
            destinyCellNumber.removeAll()
            simuDestinyCellNumber.removeAll()
            if pinPoint1.count > 0 {
                for i in 0...pinPoint1.count-1 {
                    let path = pathForIdentifier(bunchOfId[i])
                    do {
                        try NSFileManager.defaultManager().removeItemAtPath(path)
                    } catch _ {}
                    sharedContext.deleteObject(pinPoint1[i])
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
    
    @IBAction func ScatterView(sender: AnyObject) {
        editingButton.enabled = true
        destinyNumber = 1
        collectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.Top, animated: false)
        collectionView.reloadData()
    }
    
    @IBAction func OneView(sender: AnyObject) {
        editingButton.enabled = false
        destinyNumber = 0
        collectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.Top, animated: false)
        collectionView.reloadData()
    }
    
    
    override func prefersStatusBarHidden() -> Bool {
        return false
    }
    
    lazy var sharedContext: NSManagedObjectContext =  {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    func saveContext() {
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    func unDeletePhoto(sender: UIButton) {
        
        let i : Int = (sender.layer.valueForKey("index")) as! Int
        self.destinyCellNumber = self.simuDestinyCellNumber
        for m in 0...destinyCellNumber.count - 1 {
            if i == destinyCellNumber[m]{
                bunchOfId.removeAtIndex(m)
                simuDestinyCellNumber.removeAtIndex(m)
                self.pinPoint1.removeAtIndex(m)
            }
        }
    }
    
    func pathForIdentifier(identifier: String) -> String {
        let documentsDirectoryURL: NSURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        let fullURL = documentsDirectoryURL.URLByAppendingPathComponent(identifier)
        return fullURL.path!
    }
}