//
//  TestVC1.swift
//  GesturePin
//
//  Created by Xiaochao Luo on 2016-05-17.
//  Copyright © 2016 Xiaochao Luo. All rights reserved.
//

import Foundation
import UIKit


class TestVC1: UIViewController {
    
    var JustANumber: Int = 0
    
    
    
    override func viewDidLoad() {
        print(JustANumber)
    }
    
    
    @IBAction func GoT2(sender: AnyObject) {
        
       let controller = storyboard!.instantiateViewControllerWithIdentifier("TestVC2") as! TestVC2
        
    self.presentViewController(controller, animated: false, completion: nil)


    }
    
    
    
    
    
}