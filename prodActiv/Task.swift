//
//  event.swift
//  prodActiv
//
//  Created by Jaime Alberto Gonzalez on 3/22/19.
//  Copyright © 2019 Jaime Alberto Gonzalez. All rights reserved.
//

import UIKit

class Task: NSObject, NSCoding {
    
    var title : String = ""
    var date : Date = Date()
    var tag : Tag!
    var done : Bool = false
    
    init(title : String, date : Date, tag : Tag, done : Bool) {
        self.title = title
        self.date = date
        self.tag = tag
        self.done = done
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(title, forKey: "title")
        aCoder.encode(date, forKey: "date")
        aCoder.encode(tag, forKey: "tag")
        aCoder.encode(done as Any, forKey: "done")
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.title = aDecoder.decodeObject(forKey: "title") as! String
        self.date = aDecoder.decodeObject(forKey: "date") as! Date
        self.tag = (aDecoder.decodeObject(forKey: "tag") as! Tag)
        self.done = aDecoder.decodeObject(forKey: "done") as! Bool
    }

}
