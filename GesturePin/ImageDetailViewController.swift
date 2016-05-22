//
//  ImageDetailViewController.swift
//  GesturePin
//
//  Created by Xiaochao Luo on 2016-05-09.
//  Copyright © 2016 Xiaochao Luo. All rights reserved.
//

import UIKit

class ImageDetailViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    

    var imageLists: [image] {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).imageList
    }
    
    
    var DetailedImage : image!

    
    var imageS = UIImage()

    
    override func viewWillAppear(animated: Bool) {
        self.imageView.image = DetailedImage.imageFromLocation
//        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//        appDelegate.imageList.removeAll()
    }
    
    @IBAction func Dismiss(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    
    


}
