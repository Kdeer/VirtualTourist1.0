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
    
    @IBOutlet weak var goT2: UIButton!
    
    
    override func viewDidLoad() {

    }
    
    
    @IBAction func GoT2(sender: AnyObject) {
        print(JustANumber)
        self.goT2.enabled = true
//       let controller = storyboard!.instantiateViewControllerWithIdentifier("TestVC2") as! TestVC2
//        
//    self.navigationController!.pushViewController(controller, animated: true)


    }
    
    
    
    
    
}