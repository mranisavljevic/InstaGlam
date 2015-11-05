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
    
    class func savePost(post: Status?, completion: (saved: Bool, error: NSError?) -> ()) {
        if let post = post {
            let parseStatusClass = PFObject(className: kParseStatusClass)
            if let imageData = UIImageJPEGRepresentation(post.statusImage!, 1.0) {
                let imageFile = PFFile(data: imageData)
                parseStatusClass["statusUpdateImageData"] = imageFile
                parseStatusClass["statusUpdateMessage"] = post.statusUpdate
                parseStatusClass.saveInBackgroundWithBlock { (saved, error) -> Void in
                    if saved {
                        completion(saved: true, error: nil)
                    } else {
                        completion(saved: false, error: error)
                    }
                }
            }
        }
    }
    
    class func fetchPosts(completion: (objects: [Status]?) -> ()) {
        let statusQuery = PFQuery(className: kParseStatusClass)
        statusQuery.findObjectsInBackgroundWithBlock { (results, error) -> Void in
            if error != nil {
                print("Error fetching posts: \(error)")
            } else {
                if let results = results {
                    var statusArray = [Status]()
                    for result in results {
                        let imageFile = result["statusUpdateImageData"] as! PFFile
                        let messageText = result["statusUpdateMessage"]as! String
                        let status = Status(statusUpdate: messageText, statusImageFile: imageFile)
                        statusArray.append(status)
                    }
                    completion(objects: statusArray)
                }
            }
        }
    }
}
