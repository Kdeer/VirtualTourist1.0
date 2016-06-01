//
//  TestCollectionViewCell.swift
//  GesturePin
//
//  Created by Xiaochao Luo on 2016-05-12.
//  Copyright © 2016 Xiaochao Luo. All rights reserved.
//

import Foundation
import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var closingImage: UIButton!
    
    @IBOutlet weak var Adicator: UIActivityIndicatorView!
    
    
    @IBAction func ClosingImage(sender: AnyObject) {
        self.closingImage.hidden = true
    }
    
    
    
    
    var taskToCancelifCellIsReused: NSURLSessionTask? {
        
        didSet {
            if let taskToCancel = oldValue {
                taskToCancel.cancel()
            }
        }
    }
    
    
    
    
    
    
}