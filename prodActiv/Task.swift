//
//  event.swift
//  prodActiv
//
//  Created by Jaime Alberto Gonzalez on 3/22/19.
//  Copyright © 2019 Jaime Alberto Gonzalez. All rights reserved.
//

import UIKit

class Task: NSObject {
    
    var title : String = ""
    var date : Date = Date()
    var time : String = ""
    var tag : String = ""
    var done : Bool = false
    
    init(title : String, date : Date, time : String, tag : String, done : Bool) {
        self.title = title
        self.date = date
        self.time = time
        self.tag = tag
        self.done = done
    }

}
