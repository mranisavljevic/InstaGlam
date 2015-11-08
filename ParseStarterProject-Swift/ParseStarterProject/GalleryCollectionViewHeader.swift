//
//  GalleryCollectionViewHeader.swift
//  InstaGlam
//
//  Created by Miles Ranisavljevic on 11/7/15.
//  Copyright © 2015 creeperspeak. All rights reserved.
//

import UIKit

protocol GalleryCollectionViewHeaderDelegate {
    func didChangeGallerySource(source: String)
}

class GalleryCollectionViewHeader: UICollectionReusableView {
    @IBOutlet weak var galleryHeaderTitleLabel: UILabel!
    
    var delegate: GalleryCollectionViewHeaderDelegate?
        
    @IBAction func changeGalleryButtonPressed(sender: UIButton) {
        var newGallery = ""
        if self.galleryHeaderTitleLabel.text == "Cloud Gallery" {
            newGallery = "InstaGlam"
        } else {
            newGallery = "Cloud Gallery"
        }
        if let delegate = self.delegate {
            delegate.didChangeGallerySource(newGallery)
        }
    }
}
