//
//  GalleryCollectionViewCell.swift
//  InstaGlam
//
//  Created by Miles Ranisavljevic on 11/4/15.
//  Copyright © 2015 creeperspeak. All rights reserved.
//

import UIKit

class GalleryCollectionViewCell: UICollectionViewCell {
    
    var status: Status? {
        didSet {
            if let image = status?.statusImage {
                self.cellImageView.image = image
            }
        }
    }
    
    @IBOutlet weak var cellImageView: UIImageView!
    
}
