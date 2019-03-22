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
    var date : String = ""
    var time : String = ""
    
    init(title : String, date : String, time : String) {
        self.title = title
        self.date = date
        self.time = time
    }

}
