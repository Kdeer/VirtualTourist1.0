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

var cacheDestinyNumber: Int = 0


class CollectionViewController: UIViewController, CacheDelegate{
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var editingButton: UIBarButtonItem!
    @IBOutlet weak var TeamStack: UIStackView!
    @IBOutlet weak var freshButton: UIBarButtonItem!
    
    
    var imageLists: [image] {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).imageList
    }
    
    var destinyNumber: Int = 1
    var destinyCellNumber: [Int] = []
    var simuDestinyCellNumber: [Int] = []
    var cellHeight: Int = 0
    var cellWidth: Int = 0
    
    var pinPoint: Pin!
    var pinPoint1 = [ImageInfo]()
    
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    
    func cacheNotification(didFinishNumber: Int) {
        if didFinishNumber >= 10 {
            self.freshButton.enabled = true
        }
    }
    
    func enableTheButton(){
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate.imageList.removeAll()
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
        print(cacheDestinyNumber)
        

        
        if pinPoint.imageinfos.isEmpty {
            self.getMeImages()
        }
        


    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowLocation"  {
            
            let LocationTableVC: LocationTableViewController = segue.destinationViewController as! LocationTableViewController
            
        } else if segue.identifier == "DetailImage"{
            let path = collectionView.indexPathsForSelectedItems()
            let selectedPath = path?.first
            
            let ImageDetailVC: ImageDetailViewController = segue.destinationViewController as! ImageDetailViewController
            ImageDetailVC.DetailedImage = imageLists[(selectedPath?.row)!]
        }
    }
    
    func refreshPage(completionHandler: (success: Bool, error: String?) -> Void) {
//        cacheDestinyNumber = 0
        print(pinPoint.imageinfos.count)
        if self.pinPoint.imageinfos.count > 30 {
            for item in self.collectionView!.visibleCells() as![CollectionViewCell] {
                let indexPath : NSIndexPath = self.collectionView!.indexPathForCell(item as CollectionViewCell)!
                let imageCollection = pinPoint.imageinfos[indexPath.row]
                imageCollection.pinPoint = nil
                self.sharedContext.deleteObject(imageCollection)
                self.saveContext()
            }
            
        }else if self.pinPoint.imageinfos.isEmpty {
            self.getMeImages()

        }
        
        performUIUpdatesOnMain(){
            self.collectionView.reloadData()

        }
        
        completionHandler(success: true, error: nil)
        
        
    }
    
    class func sharedInstance() -> CollectionViewController {
        struct Singleton {
            static var sharedInstance = CollectionViewController()
        }
        return Singleton.sharedInstance
    }
    
    var anotherDestinyNumber: Int = 0
    
    @IBAction func FreshButton(sender: AnyObject) {
        cacheDestinyNumber = 0
        refreshPage{(success, error) in
            if success {
                let item = self.collectionView!.visibleCells() as![CollectionViewCell]
                
                for i in 0...15 {
                    if item[i].Adicator.hidden == false {
                        cacheDestinyNumber = 1
                    }
                }
            }
        }
    }
    
    @IBAction func Editing(sender: AnyObject) {
        
        if self.editingButton.title == "Edit" {
            self.editingButton.title = "Done"
            for item in self.collectionView!.visibleCells() as![CollectionViewCell] {
                let indexPath : NSIndexPath = self.collectionView!.indexPathForCell(item as CollectionViewCell)!
                let cell = collectionView.cellForItemAtIndexPath(indexPath) as! CollectionViewCell
                cell.imageView.alpha = 0.5
            }

        }else {
            self.editingButton.title = "Edit"
            for item in self.collectionView!.visibleCells() as![CollectionViewCell] {
                let indexPath : NSIndexPath = self.collectionView!.indexPathForCell(item as CollectionViewCell)!
                let cell = collectionView.cellForItemAtIndexPath(indexPath) as! CollectionViewCell
                cell.imageView.alpha = 1
                self.destinyCellNumber.removeAll()
                self.simuDestinyCellNumber.removeAll()
                
                
            }
            if pinPoint1.count > 0 {
                for i in 0...pinPoint1.count-1 {
                    self.sharedContext.deleteObject(pinPoint1[i])
                    self.saveContext()
                }
            }
            self.pinPoint1.removeAll()
        self.collectionView!.reloadData()
        }
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
    
    func getMeImages() {
        self.freshButton.enabled = false
            VirtualTouristClient.sharedInstance().imagesAtLocation(self.latitude, longitude: self.longitude){(success, result, error) in
                if success {
                    if let imageDictionary = result.valueForKey("photo") as? [[String:AnyObject]] {
                        
                        performUIUpdatesOnMain(){
                        _ = imageDictionary.map(){(dictionary: [String:AnyObject]) -> ImageInfo in
                            let imageList1 = ImageInfo(dictionary: dictionary, context: self.sharedContext)
                            imageList1.pinPoint = self.pinPoint

                            return imageList1
                        }

                            self.collectionView!.reloadData()
                        self.saveContext()
                            self.freshButton.enabled = true
                        }
                    }
                }else if result == nil{
                    print("Here is no photos")
                }
            }
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
    
    func deletePhoto(sender: UIButton) {
        
        let path = collectionView.indexPathsForSelectedItems()
        let i : Int = (sender.layer.valueForKey("index")) as! Int
        
        self.destinyCellNumber = self.simuDestinyCellNumber
        
        print(self.destinyCellNumber)
        
        for m in 0...destinyCellNumber.count - 1 {
            if i == destinyCellNumber[m]{
                print(i,m)
                simuDestinyCellNumber.removeAtIndex(m)
                self.pinPoint1.removeAtIndex(m)
        }

        }

//        print("anti\(i)")
//        let path = collectionView.indexPathsForVisibleItems()
//        path.reverse()
//        print(path.reverse())
//        if let item = self.collectionView!.visibleCells() as? [CollectionViewCell] {
//            let indexpath : NSIndexPath = self.collectionView!.indexPathForCell(item[0] as CollectionViewCell)!
//            item[indexpath.row].closingImage.hidden = true
        
//        let cell = collectionView.cellForItemAtIndexPath(path) as! CollectionViewCell
        
//        self.collectionView!.reloadData()
    }
    
    func undelete(sender: UIButton, indexPath: NSIndexPath){
//        let cell = collectionView.cellForItemAtIndexPath() as! CollectionViewCell
//        if cell.closingImage.hidden == false {
//            cell.closingImage.hidden = true
//        }
    }
}

extension CollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let MinColumns : Int = 16
        
        return min(pinPoint.imageinfos.count, MinColumns)
//                return pinPoint.imageinfos.count
        //        return 5
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CollectionViewCell", forIndexPath: indexPath) as! CollectionViewCell
        cell.Adicator.hidden = false
        cell.Adicator.startAnimating()
        let imageRow = pinPoint.imageinfos[indexPath.row]
        var posterImage = UIImage()
        cell.imageView.contentMode = .ScaleAspectFill
        if imageRow.imageURL == nil || imageRow.imageURL == "" {
            posterImage = UIImage()
        }else if imageRow.posterImage != nil {

            posterImage = imageRow.posterImage!
            
            cell.Adicator.stopAnimating()
            cell.Adicator.hidden = true
        } else {
            
            let task = VirtualTouristClient.sharedInstance().taskForImages(imageRow.imageURL)
            {(imageData, error) in
                
                if let data = imageData {
                    let image1 = UIImage(data:data)
                    imageRow.posterImage = image1
                    
                    performUIUpdatesOnMain(){
                        cell.imageView.image = image1
                        cell.Adicator.stopAnimating()
                        cell.Adicator.hidden = true
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
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.allowsMultipleSelection = true
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! CollectionViewCell
        
//        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CollectionViewCell", forIndexPath: indexPath) as! CollectionViewCell

        if editingButton.title == "Done" {
            destinyCellNumber += [indexPath.row]
            self.simuDestinyCellNumber += [indexPath.row]
//            let item = self.collectionView!.visibleCells() as! [CollectionViewCell]
//            print(item[indexPath.row],indexPath.row)
//            item[indexPath.row].closingImage.hidden = false
            cell.closingImage.viewWithTag(102)
            cell.closingImage.hidden = false
            //        cell.imageView.alpha = 0.5
            let imageCollection = self.pinPoint.imageinfos[indexPath.row]
            self.pinPoint1.append(imageCollection)
        }else if editingButton.title == "Edit"{
            print(simuDestinyCellNumber)
            let controller = storyboard!.instantiateViewControllerWithIdentifier("ImageDetailViewController") as! ImageDetailViewController
            let theImage = image(imageFromLocation: cell.imageView.image)
            controller.DetailedImage = theImage
            self.navigationController!.pushViewController(controller, animated: true)
        }
        else{
            cell.closingImage.hidden = true
        }
    }
    
    //Mark: collectionView frame size for 4 cells in a row, works out for both iphone6 and iphone 6plus screen size
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        if destinyNumber == 1 {
        if collectionView.frame.width < 400 {
            flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }else if collectionView.frame.width > 400 {
        flowLayout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        }
        flowLayout.minimumInteritemSpacing = 1
        flowLayout.minimumLineSpacing = 1
        return CGSize(width: collectionView.frame.width/4.05, height: collectionView.frame.width/4.05)
        } else {
            flowLayout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            flowLayout.minimumLineSpacing = 5
            return CGSize(width: 350, height: 350)
        }
        
    }
}
    
  //Mark: frame size for cells 3 in a row, works both for iphone6 and plus.
    
//    let width = (CGRectGetWidth(collectionView.frame) - 20) / 3
//    flowLayout.minimumInteritemSpacing = 1
//    flowLayout.minimumLineSpacing = 1
//    return CGSize(width: collectionView.frame.width/3.025, height: collectionView.frame.width/3.1)
    
//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
//        
//        flowLayout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
//        flowLayout.minimumInteritemSpacing = 0
//        
//        print(collectionView.frame.width)
//        
//        if self.destinyNumber == 1 && collectionView.frame.width == 375{
//            self.cellWidth = 124
//            self.cellHeight = 118
//            flowLayout.minimumLineSpacing = 1
//        } else if self.destinyNumber == 1 && collectionView.frame.width == 414 {
//            
//            self.cellWidth = 13
//            
//            
//            
//            
//        }
//        else {
//            self.cellWidth = 350
//            self.cellHeight = 350
//            flowLayout.minimumLineSpacing = 5
//            
//        }
//        return CGSize(width: self.cellWidth, height: self.cellHeight)
//    }


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


//    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
//        return 1
//    }

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
