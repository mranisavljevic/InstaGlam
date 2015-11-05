//
//  Status.swift
//  InstaGlam
//
//  Created by Miles Ranisavljevic on 11/3/15.
//  Copyright © 2015 creeperspeak. All rights reserved.
//

import UIKit
import Parse

class Status {
    var statusImage: UIImage?
    let statusUpdate: String
    let statusImageFile: PFFile?
    
    init(statusImage: UIImage? = nil, statusUpdate: String, statusImageFile: PFFile? = nil) {
        self.statusImage = statusImage
        self.statusUpdate = statusUpdate
        self.statusImageFile = statusImageFile
    }
}
