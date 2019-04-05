//
//  Tag.swift
//  prodActiv
//
//  Created by Kevin Radtke on 3/25/19.
//  Copyright © 2019 Jaime Alberto Gonzalez. All rights reserved.
//

import UIKit

class Tag: NSObject, NSCoding {
    
    var name : String!
    var color : UIColor!
    
    init(name: String, color: UIColor) {
        self.name = name
        self.color = color
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey:"name")
        aCoder.encode(color, forKey: "color")
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.name = aDecoder.decodeObject(forKey: "name") as! String
        self.color = aDecoder.decodeObject(forKey: "color") as! UIColor
    }
    
    
    
}
