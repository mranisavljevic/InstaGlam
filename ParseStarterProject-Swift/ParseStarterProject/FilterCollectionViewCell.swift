//
//  FilterCollectionViewCell.swift
//  InstaGlam
//
//  Created by Miles Ranisavljevic on 11/5/15.
//  Copyright © 2015 creeperspeak. All rights reserved.
//

import UIKit

class FilterCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var filterCellImage: UIImageView!
    
    @IBOutlet weak var cellFilterNameLabel: UILabel!
    
    var filteredImage: UIImage? {
        didSet {
            if let image = filteredImage {
                let size = CGSize(width: 100, height: 100)
                let thumbnail = UIImage.resizeImage(image, size: size)
                self.filterCellImage.image = thumbnail
            }
        }
    }
    
    var filterName: String? {
        didSet {
            if let name = filterName {
                self.cellFilterNameLabel.text = name
            }
        }
    }
}
