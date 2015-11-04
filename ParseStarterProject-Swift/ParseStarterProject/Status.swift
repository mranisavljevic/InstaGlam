//
//  Status.swift
//  InstaGlam
//
//  Created by Miles Ranisavljevic on 11/3/15.
//  Copyright © 2015 creeperspeak. All rights reserved.
//

import UIKit

class Status {
    let statusImage: UIImage
    let statusUpdate: String?
    
    init(statusImage: UIImage, statusUpdate: String? = nil) {
        self.statusImage = statusImage
        self.statusUpdate = statusUpdate
    }
}
