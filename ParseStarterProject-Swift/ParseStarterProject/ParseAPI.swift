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
    
    class func savePost(post: Status?) {
        if let post = post {
            let parseStatusClass = PFObject(className: kParseStatusClass)
            if let imageData = UIImageJPEGRepresentation(post.statusImage, 1.0) {
                let imageFile = PFFile(data: imageData)
                parseStatusClass["statusUpdateImageData"] = imageFile
                if let updateMessage = post.statusUpdate {
                    parseStatusClass["statusUpdateMessage"] = updateMessage
                }
                parseStatusClass.saveInBackgroundWithBlock { (saved, error) -> Void in
                    if saved {
                        print("Successfully saved.")
                    } else {
                        print("Error code: \(error?.code)")
                    }
                }
            }
        }
    }
    
    class func fetchPosts(completion: (objects: [PFObject]?) -> ()) {
        let statusQuery = PFQuery(className: kParseStatusClass)
        statusQuery.findObjectsInBackgroundWithBlock { (results, error) -> Void in
            if error != nil {
                print("Error fetching posts: \(error)")
            } else {
                if let results = results {
                    print("Got some objects: \(results.count)")
                    completion(objects: results)
                }
            }
        }
    }
    
    class func convertPFObjectToStatus(object: PFObject, completion: (status: Status?, error: Bool) -> ()) {
        if let imageFile = object["statusUpdateImageData"] as? PFFile {
            imageFile.getDataInBackgroundWithBlock({ (data, error) -> Void in
                if error != nil {
                    print("Error fetching image data")
                    completion(status: nil, error: true)
                } else {
                    if let imageData = data {
                        let image = UIImage(data: imageData)
                        let text = object["statusUpdateMessage"] as! String
                        let status = Status(statusImage: image!, statusUpdate: text)
                        completion(status: status, error: false)
                    }
                }
            })
        }
    }
    
    
//    class func fetchPosts() -> [Status]? {
//        let statusQuery = PFQuery(className: kParseStatusClass)
//        var statusResults = [Status]()
//        statusQuery.findObjectsInBackgroundWithBlock { (results, error) -> Void in
//            if error != nil {
//                print("Error fetching posts: \(error)")
//            } else {
//                if let fetchedPosts = results {
//                    for object in fetchedPosts {
//                        if let postImageFile = object["statusUpdateImageData"] as? PFFile {
//                            postImageFile.getDataInBackgroundWithBlock({ (imageData, error) -> Void in
//                                if error != nil {
//                                    print("Error downloading image data: \(error)")
//                                } else {
//                                    if let imageDataReturned = imageData {
//                                        var message: String? = nil
//                                        if let statusMessage = object["statusUpdateMessage"] as? String {
//                                            message = statusMessage
//                                        }
//                                        if let image = UIImage(data: imageDataReturned) {
//                                            let post = Status(statusImage: image, statusUpdate: message)
//                                            statusResults.append(post)
//                                        }
//                                    }
//                                }
//                            })
//                        }
//                    }
//                }
//            }
//        }
//        if statusResults.count > 0 {
//            return statusResults
//        } else {
//            return nil
//        }
//    }
}
