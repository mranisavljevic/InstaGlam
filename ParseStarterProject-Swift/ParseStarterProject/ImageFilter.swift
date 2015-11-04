//
//  ImageFilter.swift
//  InstaGlam
//
//  Created by Miles Ranisavljevic on 11/3/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit

class Filter {
    private class func makeFilter(withImage image: UIImage, name: String, parameters: [String : AnyObject]?) -> UIImage? {
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
    
    private class func makeFilter(name: String, parameters: [String : AnyObject]?) -> UIImage? {
        let filter: CIFilter
        if let parameters = parameters {
            filter = CIFilter(name: name, withInputParameters: parameters)!
        } else {
            filter = CIFilter(name: name)!
        }
        
        let options = [kCIContextWorkingColorSpace : NSNull()]
        let eaglContext = EAGLContext(API: EAGLRenderingAPI.OpenGLES2)
        let gpuContext = CIContext(EAGLContext: eaglContext, options: options)
        
        let rect = CGRectMake(0.0, 0.0, 600.0, 600.0)
        
        let filteredImage = filter.outputImage
        let extent = rect
        let cgImage = gpuContext.createCGImage(filteredImage!, fromRect: extent)
        
        let finalImage = UIImage(CGImage: cgImage)
        return finalImage
        
    }
    
    private class func blendPhotos(name: String, image: UIImage, backgroundImage: UIImage) -> UIImage? {
        let inputImage = CIImage(image: image)
        let inputBackgroundImage = CIImage(image: backgroundImage)
        let filter = CIFilter(name: name)!
        
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        filter.setValue(inputBackgroundImage, forKey: kCIInputBackgroundImageKey)
        
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
        
        if let filteredImage = self.makeFilter(withImage: image, name: filterName, parameters: nil) {
            completion(filteredImage: filteredImage, name: displayName)
        }
    }
    
    class func applyCrystallizeFilter(image: UIImage, completion: (filteredImage: UIImage?, name: String) -> Void) {
        let filterName = Constants.crystallizeFilter
        let displayName = "Crystallize"
        
        if let filteredImage = self.makeFilter(withImage: image, name: filterName, parameters: nil) {
            completion(filteredImage: filteredImage, name: displayName)
        }
    }
    
    class func applyProcessFilter(image: UIImage, completion: (filteredImage: UIImage?, name: String) -> Void) {
        let filterName = Constants.colorProcessFilter
        let displayName = "Cross Process"
        
        if let filteredImage = self.makeFilter(withImage: image, name: filterName, parameters: nil) {
            completion(filteredImage: filteredImage, name: displayName)
        }
    }
    
    class func applyGlassLozengeFilter(image: UIImage, completion: (filteredImage: UIImage?, name: String) -> Void) {
        let filterName = Constants.glassLozengeFilter
        let displayName = "Glass Lozenge?"
        let input0x = CGFloat((rand() % 600))
        let input0y = CGFloat((rand() % 600))
        let vector0 = CIVector(x: input0x, y: input0y)
        let input1x = CGFloat((rand() % 600))
        let input1y = CGFloat((rand() % 600))
        let vector1 = CIVector(x: input1x, y: input1y)
        var parameters = [String : AnyObject]()
        parameters["inputPoint0"] = vector0
        parameters["inputPoint1"] = vector1
        
        if let filteredImage = self.makeFilter(withImage: image, name: filterName, parameters: parameters) {
            completion(filteredImage: filteredImage, name: displayName)
        }
    }
    
    class func applyLenticularHalo(image: UIImage, completion: (filteredImage: UIImage?, name: String) -> Void) {
        let filterName = Constants.lenticularHaloFilter
        let displayName = "Lenticular Halo"
        let color = CIColor(red: 1.0, green: 1.0, blue: 1.0)
        let inputCenterX = CGFloat((rand() % 600))
        let inputCenterY = CGFloat((rand() % 600))
        let centerVector = CIVector(x: inputCenterX, y: inputCenterY)
        let inputRadius = CGFloat((rand() % 100))
        let inputWidth = CGFloat((rand() % 100))
        var parameters = [String: AnyObject]()
        parameters["inputColor"] = color
        parameters["inputCenter"] = centerVector
        parameters["inputHaloRadius"] = inputRadius
        parameters["inputHaloWidth"] = inputWidth
        
        if let drawnImage = self.makeFilter(filterName, parameters: parameters) {
            print("Center: \(parameters["inputCenter"])")
            completion(filteredImage: drawnImage, name: displayName)
        }
    }
    
    class func blendHalo(image: UIImage, backgroundImage: UIImage, completion: (filteredImage: UIImage?, name: String) -> Void) {
        let blendName = Constants.screenBlendMode
        let displayName = "Screen Blend"
        if let blendedImage = self.blendPhotos(blendName, image: image, backgroundImage: backgroundImage) {
            completion(filteredImage: blendedImage, name: displayName)
        }
    }
    
    class func applyBumpDistortionLinear(image: UIImage, completion: (filteredImage: UIImage?, name: String) -> Void) {
        let filterName = Constants.bumpDistortionLinearFilter
        let displayName = "Linear Bump"
        let inputCenterX = CGFloat((rand() % 600))
        let inputCenterY = CGFloat((rand() % 600))
        let inputRadius = CGFloat((rand() % 600))
        let centerVector = CIVector(x: inputCenterX, y: inputCenterY)
        let inputAngle = CGFloat((CGFloat(rand()) % 600.0) / (CGFloat(rand() % 600)) % CGFloat(1.0))
        let inputScale = CGFloat((CGFloat(rand()) % 600.0) / (CGFloat(rand() % 600)) % CGFloat(1.0))
        var parameters = [String : AnyObject]()
        parameters["inputCenter"] = centerVector
        parameters["inputRadius"] = inputRadius
        parameters["inputAngle"] = inputAngle
        parameters["inputScale"] = inputScale
        
        if let filteredImage = self.makeFilter(withImage: image, name: filterName, parameters: parameters) {
            completion(filteredImage: filteredImage, name: displayName)
        }
    }
    
    class func applyHoleDistortion(image: UIImage, completion: (filteredImage: UIImage?, name: String) -> Void) {
        let filterName = Constants.holeDistortionFilter
        let displayName = "Hole Distortion"
        let inputCenterX = CGFloat((rand() % 600))
        let inputCenterY = CGFloat((rand() % 600))
        let holeRadius = CGFloat((rand() % 100))
        let centerVector = CIVector(x: inputCenterX, y: inputCenterY)
        var parameters = [String : AnyObject]()
        parameters["inputCenter"] = centerVector
        parameters["inputRadius"] = holeRadius
        
        if let filteredImage = self.makeFilter(withImage: image, name: filterName, parameters: parameters) {
            completion(filteredImage: filteredImage, name: displayName)
        }
    }

}
