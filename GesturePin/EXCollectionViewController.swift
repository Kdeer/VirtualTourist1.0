//
//  EXCollectionViewController.swift
//  GesturePin
//
//  Created by Xiaochao Luo on 2016-06-02.
//  Copyright © 2016 Xiaochao Luo. All rights reserved.
//

import Foundation
import UIKit


extension CollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return min(self.pinPoint.imageinfos.count, 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
        cell.Adicator.isHidden = false
        cell.Adicator.startAnimating()
        let imageRow = pinPoint.imageinfos[(indexPath as NSIndexPath).row]
        var posterImage = UIImage()
        cell.imageView.contentMode = .scaleAspectFill
        if imageRow.imageURL == nil || imageRow.imageURL == "" {
            posterImage = UIImage()
        }else if imageRow.posterImage != nil {
            posterImage = imageRow.posterImage!
            cell.Adicator.stopAnimating()
            cell.Adicator.isHidden = true
            
        } else {

            let task = VirtualTouristClient.sharedInstance().taskForImages(imageRow.imageURL)
            {(imageData, error) in
                if let data = imageData {
                    
                    performUIUpdatesOnMain(){
                    let image1 = UIImage(data:data)
                    imageRow.posterImage = image1
                    
                        cell.imageView.image = image1
                        cell.Adicator.stopAnimating()
                        cell.Adicator.isHidden = true
                    }
                    
                }
            }
            cell.taskToCancelifCellIsReused = task
        }
        cell.closingImage.layer.setValue((indexPath as NSIndexPath).row, forKey: "index")
        cell.closingImage.addTarget(self, action: #selector(self.unDeletePhoto(_:)), for: UIControlEvents.touchUpInside)
        
        cell.closingImage.isHidden = true
        cell.imageView.image = posterImage
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! CollectionViewCell
        
        if editingButton.title == "Done" {
            simuDestinyCellNumber += [(indexPath as NSIndexPath).row]
            cell.closingImage.viewWithTag(102)
            cell.closingImage.isHidden = false
            let imageCollection = self.pinPoint.imageinfos[(indexPath as NSIndexPath).row]
            print(imageCollection)
            pinPoint1.append(imageCollection)
            let imageCollectionID = self.pinPoint.imageinfos[(indexPath as NSIndexPath).row].id
            bunchOfId.append(imageCollectionID!)
        }else if editingButton.title == "Edit"{
            let controller = storyboard!.instantiateViewController(withIdentifier: "ImageDetailViewController") as! ImageDetailViewController
            let theImage = image(imageFromLocation: cell.imageView.image)
            controller.DetailedImage = theImage
            print(self.pinPoint.imageinfos[(indexPath as NSIndexPath).row].id)
            self.navigationController!.pushViewController(controller, animated: true)
        }
    }
    
    //Mark: collectionView frame size for 4 cells in a row, works out for both iphone6 and iphone 6plus screen size
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        
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
    
    //mark: getImage function
    func getMeImages() {
        self.freshButton.isEnabled = false
        VirtualTouristClient.sharedInstance().imagesAtLocation(self.latitude, longitude: self.longitude){(success, result, error) in
            if success {
                
                if let imageDictionary = result?.value(forKey: "photo") as? [[String:AnyObject]] {
                    
                    if imageDictionary.isEmpty {
                        self.editingButton.isEnabled = false
                        let alertController = UIAlertController(title: "Alert", message: "So far no one takes picture here", preferredStyle: .alert)
                        let deleteAction = UIAlertAction(title: "Delete Pin", style: .default) {
                            (action) in
                            self.sharedContext.delete(self.pinPoint)
                            self.saveContext()
                            self.navigationController?.popToRootViewController(animated: true)
                        }
                        alertController.addAction(deleteAction)
                        
                        let keepAction = UIAlertAction(title: "Keep It", style: .default){
                            (action) in
                        }
                        alertController.addAction(keepAction)
                        self.present(alertController, animated: true, completion: nil)
                        
                        
                    } else
                        if imageDictionary.count < 16 && imageDictionary.count > 0 {
                            self.editingButton.isEnabled = true
                            let imageDictionary1 = imageDictionary[0...imageDictionary.count-1]
                            performUIUpdatesOnMain(){
                                let _ = imageDictionary1.map(){(dictionary: [String:AnyObject]) -> ImageInfo in
                                    let imageList1 = ImageInfo(dictionary: dictionary, context: self.sharedContext)
                                    imageList1.pinPoint = self.pinPoint
                                    
                                    return imageList1
                                }
                                
                                self.collectionView!.reloadData()
                                self.saveContext()
                                self.freshButton.isEnabled = true
                            }
                        }else {
                            self.editingButton.isEnabled = true
                            var m = Int(arc4random_uniform(UInt32(imageDictionary.count)))
                            while m + 15 >= imageDictionary.count {
                                m = Int(arc4random_uniform(UInt32(imageDictionary.count)))
                            }
                            let imageDictionary1 = imageDictionary[m...m+15]
                            performUIUpdatesOnMain(){
                                let _ = imageDictionary1.map(){(dictionary: [String:AnyObject]) -> ImageInfo in
                                    let imageList1 = ImageInfo(dictionary: dictionary, context: self.sharedContext)
                                    imageList1.pinPoint = self.pinPoint
                                    
                                    return imageList1
                                }
                                
                                self.collectionView!.reloadData()
                                self.saveContext()
                                self.freshButton.isEnabled = true
                            }
                    }
                }
            }else if result == nil{
                print("Here is no photos")
            }
        }
        
    }
}
