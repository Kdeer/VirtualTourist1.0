//
//  TestVC2.swift
//  GesturePin
//
//  Created by Xiaochao Luo on 2016-05-17.
//  Copyright © 2016 Xiaochao Luo. All rights reserved.
//

import Foundation
import UIKit


class TestVC2: UIViewController {
    
    
    
    
    
    @IBAction func GoT1(sender: AnyObject) {
        
        let controller = storyboard!.instantiateViewControllerWithIdentifier("TestVC1") as! TestVC1
        controller.JustANumber = 1
        
        self.navigationController!.pushViewController(controller, animated: true)
    }
    
    
    
    
    
    
    
}
