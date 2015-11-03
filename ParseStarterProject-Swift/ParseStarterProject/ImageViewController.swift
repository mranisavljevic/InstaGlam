//
//  ImageViewController.swift
//  InstaGlam
//
//  Created by Miles Ranisavljevic on 11/2/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit

import Parse

class ImageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let imagePickerController = UIImagePickerController()
    
    

    @IBOutlet weak var imageView: UIImageView!
    @IBAction func imagePickerButton(sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            let imagePickerAction = UIAlertController(title: "Choose Source", message: "Please choose your image source.", preferredStyle: .ActionSheet)
            let cameraAction = UIAlertAction(title: "Camera", style: .Default) { (alert) -> Void in
                self.imagePickerController.sourceType = .Camera
                self.presentViewController(self.imagePickerController, animated: true, completion: nil)
            }
            let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .Default) { (alert) -> Void in
                self.imagePickerController.sourceType = .PhotoLibrary
                self.presentViewController(self.imagePickerController, animated: true, completion: nil)
            }
            imagePickerAction.addAction(cameraAction)
            imagePickerAction.addAction(photoLibraryAction)
            self.presentViewController(imagePickerAction, animated: true, completion: nil)
        } else {
            self.imagePickerController.sourceType = .PhotoLibrary
            self.presentViewController(self.imagePickerController, animated: true, completion: nil)
        }
    }
    
    @IBAction func saveButtonPressed(sender: UIButton) {
        if let image = self.imageView.image {
            ParseAPI.saveImage(image)
        }
    }
    
    @IBAction func filtersButtonPressed(sender: UIButton) {
        if let image = self.imageView.image {
            let alertController = UIAlertController(title: "Filter", message: "Pick a wacky filter.", preferredStyle: .ActionSheet)
            let ghostifyAction = UIAlertAction(title: "Ghostify", style: .Default, handler: { (alert) -> Void in
                Filter.applyGhostFilter(image, completion: { (filteredImage, name) -> Void in
                    if let filteredImage = filteredImage {
                        self.imageView.image = filteredImage
                    }
                })
            })
            let glassLozengeAction = UIAlertAction(title: "Glass Lozenge?", style: .Default, handler: { (alert) -> Void in
                Filter.applyGlassLozengeFilter(image, completion: { (filteredImage, name) -> Void in
                    if let filteredImage = filteredImage {
                        self.imageView.image = filteredImage
                    }
                })
            })
//            let lenticularHaloAction = UIAlertAction(title: "Lenticular Halo", style: .Default, handler: { (alert) -> Void in
//                Filter.applyLenticularHalo(image, completion: { (filteredImage, name) -> Void in
//                    if let filteredImage = filteredImage {
//                        self.imageView.image = filteredImage
//                    }
//                })
//            })
            let bumpDistortionAction = UIAlertAction(title: "Bump Distortion", style: .Default, handler: { (alert) -> Void in
                Filter.applyBumpDistortionLinear(image, completion: { (filteredImage, name) -> Void in
                    if let filteredImage = filteredImage {
                        self.imageView.image = filteredImage
                    }
                })
            })
            let holeDistortionAction = UIAlertAction(title: "Hole Distortion", style: .Default, handler: { (alert) -> Void in
                Filter.applyHoleDistortion(image, completion: { (filteredImage, name) -> Void in
                    if let filteredImage = filteredImage {
                        self.imageView.image = filteredImage
                    }
                })
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            alertController.addAction(ghostifyAction)
            alertController.addAction(glassLozengeAction)
//            alertController.addAction(lenticularHaloAction)
            alertController.addAction(bumpDistortionAction)
            alertController.addAction(holeDistortionAction)
            alertController.addAction(cancelAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePickerController.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        let resizedImage = UIImage.resizeImage(image, size: Constants.imagePreferredSize)
        self.imageView.image = resizedImage
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
