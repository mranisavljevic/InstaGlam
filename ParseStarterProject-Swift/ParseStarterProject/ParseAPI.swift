//
//  ParseAPI.swift
//  InstaGlam
//
//  Created by Miles Ranisavljevic on 11/3/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class ParseAPI {
    
    class func saveImage(image: UIImage?) {
        if let image = image {
            let parseImageClass = PFObject(className: Constants.kParseImageClass)
            if let imageData = UIImageJPEGRepresentation(image, 1.0) {
                let imageFile = PFFile(data: imageData)
                parseImageClass["imageData"] = imageFile
                parseImageClass.saveInBackgroundWithBlock { (saved, error) -> Void in
                    if saved {
                        print("Successfully saved.")
                    } else {
                        print("Error code: \(error?.code)")
                    }
                }
            }
        }
    }
}
