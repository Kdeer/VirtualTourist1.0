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

    var DetailedImage : image!
    
    override func viewWillAppear(_ animated: Bool) {

        self.imageView.image = DetailedImage.imageFromLocation
    }
    
    @IBAction func Dismiss(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
}
