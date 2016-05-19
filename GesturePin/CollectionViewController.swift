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

class CollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var editingButton: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    
    var destinyNumber: Int = 0
    var destinyCellNumber: Int = 1
    var cellHeight: Int = 0
    var cellWidth: Int = 0
    
    var pinPoint: Pin!
    var pinPoint1 = [ImageInfo]()
    
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    
    var imageList: [image] {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).imageList
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        
        let mapSpan = MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
        let mapCenter = CLLocationCoordinate2DMake((pinPoint?.latitude.doubleValue)!, (pinPoint?.longitude.doubleValue)!)
        let region = MKCoordinateRegion(center: mapCenter, span: mapSpan)
        mapView.setRegion(region, animated: true)
        let annotation = MKPointAnnotation()
        annotation.coordinate = mapCenter
        mapView.addAnnotation(annotation)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print(self.pinPoint1)
        if pinPoint.imageinfos.isEmpty {
            
            VirtualTouristClient.sharedInstance().imagesAtLocation(self.latitude, longitude: self.longitude){(success, result, error) in
                
                if success {
                    if let imageDictionary = result.valueForKey("photo") as? [[String:AnyObject]] {
                        
                        _ = imageDictionary.map(){(dictionary: [String:AnyObject]) -> ImageInfo in
                            let imageList1 = ImageInfo(dictionary: dictionary, context: self.sharedContext)
                            
                            imageList1.pinPoint = self.pinPoint

//                            print(self.pinPoint.imageinfos)
                            return imageList1
                        }
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            self.collectionView!.reloadData()
                            
                        }
                       self.saveContext()
                    }
                }
            }
            
        }
    }

    @IBAction func TestButton(sender: AnyObject) {
        
        
//        let controller = storyboard!.instantiateViewControllerWithIdentifier("ViewController") as! ViewController
//        
//        self.presentViewController(controller, animated: true, completion: nil)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
//    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
//        return 1
//    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
//        return min(pinPoint.imageinfos.count, 15)
        return pinPoint.imageinfos.count
//        return 5
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CollectionViewCell", forIndexPath: indexPath) as! CollectionViewCell


        let imageRow = pinPoint.imageinfos[indexPath.row]
        var posterImage = UIImage(named: "8188165_l")
        cell.imageView.contentMode = .ScaleAspectFill
        if imageRow.imageURL == nil || imageRow.imageURL == "" {
            posterImage = UIImage(named: "8188165_l")
        }else if imageRow.posterImage != nil {

            posterImage = imageRow.posterImage
        } else {
            
            let task = VirtualTouristClient.sharedInstance().taskForImages(imageRow.imageURL)
            {(imageData, error) in
                
                if let data = imageData {
                    let image1 = UIImage(data:data)
                    imageRow.posterImage = image1
                
                performUIUpdatesOnMain(){
                    cell.imageView.image = image1
                    }
                }
            }
            cell.taskToCancelifCellIsReused = task
        }
        cell.closingImage.layer.setValue(indexPath.row, forKey: "index")
        cell.closingImage.addTarget(self, action: #selector(self.deletePhoto(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        cell.closingImage.hidden = true
        cell.imageView.image = posterImage
        return cell
    }
    
    func deletePhoto(sender: UIButton) {
        let i : Int = (sender.layer.valueForKey("index")) as! Int
        print("anti\(i)")
        
//        self.pinPoint1.removeAtIndex(i)
        
 
            
            
            
//            for i in 0...paths.count-1 {
//            print(Int(paths[i].row))
//            for i in 0...paths.count{
//            let selectedPath = paths[i]
//                print(selectedPath)
//        let imageCollection = self.pinPoint.imageinfos[selectedPath.row]
//            self.pinPoint1.removeAtIndex(selectedPath.row)
            

        self.collectionView!.reloadData()
    }
    
    @IBAction func Editing(sender: AnyObject) {
        
        if self.editingButton.title == "Edit" {
            self.editingButton.title = "Done"

        }else {
            self.editingButton.title = "Edit"
            
            if pinPoint1.count > 0 {
                for i in 0...pinPoint1.count-1 {
//                    self.pinPoint1[i].pinPoint = nil
                    self.sharedContext.deleteObject(pinPoint1[i])
                    self.saveContext()
                }
            }
        self.collectionView!.reloadData()
        
    }
    }
    

    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.allowsMultipleSelection = true
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! CollectionViewCell
        if editingButton.title == "Done" {
            cell.closingImage.viewWithTag(102)
            cell.closingImage.hidden = false
//        cell.imageView.alpha = 0.5
        let imageCollection = self.pinPoint.imageinfos[indexPath.row]
            
//            if Int(indexPath.row) == 0{
//                self.pinPoint1.insert(imageCollection, atIndex: Int(indexPath.row))
//            }else{
//        self.pinPoint1.insert(imageCollection, atIndex: Int(indexPath.row))
//                print("indexPath\(Int(indexPath.row))")
//                print(pinPoint1)
        }else{
            cell.closingImage.hidden = true
        }
    }
    
//    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
//        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! CollectionViewCell
//        cell.selected = false
//        if editingButton.title == "Done"{
//            print("456")
//            cell.closingImage.viewWithTag(102)
//            cell.closingImage.hidden = true
//            cell.imageView.alpha = 1
//            self.pinPoint1.removeLast()
//            cell.selected = false
//        }
//    }
    
    
//    func collectionView(collectionView: UICollectionView, didHighlightItemAtIndexPath indexPath: NSIndexPath) {
//        
//    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    

    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        flowLayout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        flowLayout.minimumInteritemSpacing = 0

        
        if self.destinyNumber == 0{
            self.cellWidth = 124
            self.cellHeight = 118
            flowLayout.minimumLineSpacing = 1
        } else {
            self.cellWidth = 350
            self.cellHeight = 350
            flowLayout.minimumLineSpacing = 5

        }
        return CGSize(width: self.cellWidth, height: self.cellHeight)
    }
    
    @IBAction func ScatterView(sender: AnyObject) {
        self.destinyNumber = 1
        self.collectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.Top, animated: false)
        self.collectionView.reloadData()
    }
    
    @IBAction func OneView(sender: AnyObject) {
        self.destinyNumber = 0
        self.collectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.Top, animated: false)
        self.collectionView.reloadData()
    }
    
    lazy var sharedContext: NSManagedObjectContext =  {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    func saveContext() {
        CoreDataStackManager.sharedInstance().saveContext()
    }
}

//        if let paths = collectionView.indexPathsForSelectedItems()

//            for item in self.collectionView!.visibleCells() as![CollectionViewCell] {
//
//                let indexPath : NSIndexPath = self.collectionView!.indexPathForCell(item as CollectionViewCell)!
//                let cell1 : CollectionViewCell = self.collectionView!.cellForItemAtIndexPath(indexPath) as! CollectionViewCell
//                cell1.closingImage.viewWithTag(102)
//                cell1.closingImage.hidden = false
//            }

//        imageCollection.pinPoint = nil



//            collectionView.performBatchUpdates({
//                self.collectionView.deleteItemsAtIndexPaths([indexPath])
//                }, completion: nil)
//        _ = collectionView.dequeueReusableCellWithReuseIdentifier("CollectionViewCell", forIndexPath: indexPath) as! CollectionViewCell
//
//        let detailController = self.storyboard!.instantiateViewControllerWithIdentifier("ImageDetailViewController") as! ImageDetailViewController
//
//        detailController.DetailedImage = imageList[indexPath.row]
//        self.presentViewController(detailController, animated: true, completion: nil)

//                    let imagess = image(imageFromLocation: image1)
//                    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//                    appDelegate.imageList.removeAll()
//                    appDelegate.imageList.append(imagess)


//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.identifier == "ShowPicture"
//        {
//            let indexPaths = self.collectionView!.indexPathsForSelectedItems()!
//
//            let controller = segue.destinationViewController as! ImageDetailViewController
//            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//            controller.DetailedImage = appDelegate.imageList[indexPath.row]
//        }
//    }
