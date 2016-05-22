//
//  LocationTitles.swift
//  GesturePin
//
//  Created by Xiaochao Luo on 2016-05-20.
//  Copyright © 2016 Xiaochao Luo. All rights reserved.
//

import Foundation



struct LocationTitle {
    
    var titles: String!
    
    init(dictionary: [String:String]) {
        
        titles = dictionary["titles"]! as String
        
    }
    
    
}
