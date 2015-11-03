//
//  ImageFilter.swift
//  InstaGlam
//
//  Created by Miles Ranisavljevic on 11/3/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit

class Filter {
    private class func makeFilter(name: String, parameters: [String : AnyObject]?, image: UIImage) -> UIImage? {
        let inputImage = CIImage(image: image)
        let filter: CIFilter
        
        if let parameters = parameters {
            filter = CIFilter(name: name, withInputParameters: parameters)!
        } else {
            filter = CIFilter(name: name)!
        }
        
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        
        let options = [kCIContextWorkingColorSpace : NSNull()]
        let eaglContext = EAGLContext(API: EAGLRenderingAPI.OpenGLES2)
        let gpuContext = CIContext(EAGLContext: eaglContext, options: options)
        
        let filteredImage = filter.outputImage
        let extent = filteredImage!.extent
        let cgImage = gpuContext.createCGImage(filteredImage!, fromRect: extent)
        
        let finalImage = UIImage(CGImage: cgImage)
        return finalImage
    }
    
    class func applyGhostFilter(image: UIImage, completion: (filteredImage: UIImage?, name: String) -> Void) {
        let filterName = Constants.colorInvertFilter
        let displayName = "Ghostify"
        
        if let filteredImage = self.makeFilter(filterName, parameters: nil, image: image) {
            completion(filteredImage: filteredImage, name: displayName)
        }
    }
    
    class func applyGlassLozengeFilter(image: UIImage, completion: (filteredImage: UIImage?, name: String) -> Void) {
        let filterName = Constants.glassLozengeFilter
        let displayName = "Glass Lozenge?"
        
        if let filteredImage = self.makeFilter(filterName, parameters: nil, image: image) {
            completion(filteredImage: filteredImage, name: displayName)
        }
    }
    
//    class func applyLenticularHalo(image: UIImage, completion: (filteredImage: UIImage?, name: String) -> Void) {
//        let filterName = Constants.lenticularHaloFilter
//        let displayName = "Lenticular Halo"
//        let color = CIColor(red: 1.0, green: 1.0, blue: 1.0)
//        var parameters = [String: AnyObject]()
//        parameters["inputColor"] = color
//        
//        if let filteredImage = self.makeFilter(filterName, parameters: parameters, image: image) {
//            print(parameters)
//            completion(filteredImage: filteredImage, name: displayName)
//        }
//    }
    
    class func applyBumpDistortionLinear(image: UIImage, completion: (filteredImage: UIImage?, name: String) -> Void) {
        let filterName = Constants.bumpDistortionLinearFilter
        let displayName = "Linear Bump"
        
        if let filteredImage = self.makeFilter(filterName, parameters: nil, image: image) {
            completion(filteredImage: filteredImage, name: displayName)
        }
    }
    
    class func applyHoleDistortion(image: UIImage, completion: (filteredImage: UIImage?, name: String) -> Void) {
        let filterName = Constants.holeDistortionFilter
        let displayName = "Hole Distortion"
        
        if let filteredImage = self.makeFilter(filterName, parameters: nil, image: image) {
            completion(filteredImage: filteredImage, name: displayName)
        }
    }

}
