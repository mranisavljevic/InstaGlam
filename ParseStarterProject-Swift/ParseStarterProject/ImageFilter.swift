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
        let input0x = Float((rand() % 600))
        let input0y = Float((rand() % 600))
        let vector0 = CIVector(x: CGFloat(input0x), y: CGFloat(input0y))
        let input1x = Float((rand() % 600))
        let input1y = Float((rand() % 600))
        let vector1 = CIVector(x: CGFloat(input1x), y: CGFloat(input1y))
        var parameters = [String : AnyObject]()
        parameters["inputPoint0"] = vector0
        parameters["inputPoint1"] = vector1
        
        if let filteredImage = self.makeFilter(filterName, parameters: parameters, image: image) {
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
        let inputCenterX = CGFloat((rand() % 600))
        let inputCenterY = CGFloat((rand() % 600))
        let holeRadius = CGFloat((rand() % 600))
        let centerVector = CIVector(x: inputCenterX, y: inputCenterY)
        var parameters = [String : AnyObject]()
        parameters["inputCenter"] = centerVector
        parameters["inputRadius"] = holeRadius
        
        if let filteredImage = self.makeFilter(filterName, parameters: parameters, image: image) {
            completion(filteredImage: filteredImage, name: displayName)
        }
    }

}
