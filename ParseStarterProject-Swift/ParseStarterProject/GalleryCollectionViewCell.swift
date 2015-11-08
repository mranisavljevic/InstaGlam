//
//  GalleryCollectionViewCell.swift
//  InstaGlam
//
//  Created by Miles Ranisavljevic on 11/4/15.
//  Copyright © 2015 creeperspeak. All rights reserved.
//

import UIKit

class GalleryCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var cellImageView: UIImageView!
    @IBOutlet weak var cellStatusMessageLabel: UILabel!

    var status: Status? {
        didSet {
            if let image = status?.statusImage {
                self.cellImageView.image = image
            } else {
                if let imageFile = status?.statusImageFile {
                    imageFile.getDataInBackgroundWithBlock({ (data, error) -> Void in
                        if error != nil {
                            print("Error fetching image")
                        } else {
                            if let imageData = data {
                                let image = UIImage(data: imageData)
                                self.status?.statusImage = image
                                self.cellImageView.image = image
                            }
                        }
                    })
                }
            }
        }
    }
}
