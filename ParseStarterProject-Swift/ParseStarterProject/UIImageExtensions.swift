//
//  UIImageExtensions.swift
//  InstaGlam
//
//  Created by Miles Ranisavljevic on 11/3/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit

extension UIImage {
    class func resizeImage(image: UIImage, size: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(size)
        image.drawInRect(CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height))
        
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage
    }
}

extension UIColor {
    class func chartreuseColor() -> UIColor {
        return UIColor(colorLiteralRed: 89.4 / 100.0, green: 99.2 / 100.0, blue: 53.7 / 100.0, alpha: 1.0)
    }
}
