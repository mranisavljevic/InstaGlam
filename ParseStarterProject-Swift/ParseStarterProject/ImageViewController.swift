//
//  ImageViewController.swift
//  InstaGlam
//
//  Created by Miles Ranisavljevic on 11/2/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class ImageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    let imagePickerController = UIImagePickerController()
    
    let defaultImage = UIImage(named: "Logo")
    
    var filteredImages = [UIImage]() {
        didSet {
            self.filterCollectionView.reloadData()
        }
    }

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var statusMessageTextField: UITextField!
    @IBOutlet weak var filterCollectionView: UICollectionView!
    
    @IBAction func imagePickerButton(sender: UIButton) {
        imagePickerController.allowsEditing = true
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
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        let image = self.imageView.image
        if image != defaultImage {
            if let message = statusMessageTextField.text {
                if message != "" {
                    let statusPost = Status(statusImage: image, statusUpdate: message)
                    ParseAPI.savePost(statusPost, completion: { (saved, error) -> () in
                        if saved {
                            let savedAction = UIAlertController(title: "Saved", message: "Saved successfully!", preferredStyle: .Alert)
                            savedAction.addAction(okAction)
                            self.presentViewController(savedAction, animated: true, completion: { () -> Void in
                                self.imageView.image = self.defaultImage
                                self.statusMessageTextField.text = ""
                                self.statusMessageTextField.placeholder = "Bowl cut, baby!"
                            })
                        } else {
                            if let error = error {
                                let errorAction = UIAlertController(title: "Error!", message: "Error code: \(error.code)", preferredStyle: .Alert)
                                errorAction.addAction(okAction)
                                self.presentViewController(errorAction, animated: true, completion: nil)
                            }
                        }
                    })
                } else {
                    let noTextAction = UIAlertController(title: "Oops!", message: "Please write a comment about your photo.", preferredStyle: .Alert)
                    noTextAction.addAction(okAction)
                    self.presentViewController(noTextAction, animated: true, completion: nil)
                }
            }
        } else {
            let noImageAction = UIAlertController(title: "Oops!", message: "Please capture or import a photo.", preferredStyle: .Alert)
            noImageAction.addAction(okAction)
            self.presentViewController(noImageAction, animated: true, completion: nil)
        }
    }
    
    @IBAction func filtersButtonPressed(sender: UIButton) {
        displayFilterOptions { (images) -> () in
            self.filteredImages = images
        }
    }
    
    func displayFilterOptions(completion: (images: [UIImage]) -> ()) {
        var imageArray = [UIImage]()
        if let image = self.imageView.image {
//            let thumbnailSize = CGSize(width: 50, height: 50)
//            let thumbnail = UIImage.resizeImage(image, size: thumbnailSize)
            
            
            Filter.applyGhostFilter(image, completion: { (filteredImage, name) -> Void in
                if let filtered = filteredImage {
                    imageArray.append(filtered)
                }
            })
            
            Filter.applyProcessFilter(image, completion: { (filteredImage, name) -> Void in
                if let filtered = filteredImage {
                    imageArray.append(filtered)
                }
            })
            
            Filter.applyEdgesFilter(image, completion: { (filteredImage, name) -> Void in
                if let filtered = filteredImage {
                    imageArray.append(filtered)
                }
            })
            
            Filter.applyCrystallizeFilter(image, completion: { (filteredImage, name) -> Void in
                if let filtered = filteredImage {
                    imageArray.append(filtered)
                }
            })
            
            Filter.applyGlassLozengeFilter(image, completion: { (filteredImage, name) -> Void in
                if let filtered = filteredImage {
                    imageArray.append(filtered)
                }
            })
            
            Filter.applyLenticularHalo(image, completion: { (filteredImage, name) -> Void in
                if let filteredImage = filteredImage {
                    Filter.blendHalo(filteredImage, backgroundImage: image, completion: { (filteredImage, name) -> Void in
                        if let filtered = filteredImage {
                            imageArray.append(filtered)
                        }
                    })
                }
            })
            
            Filter.applyBumpDistortionLinear(image, completion: { (filteredImage, name) -> Void in
                if let filtered = filteredImage {
                    imageArray.append(filtered)
                }
            })
            
            Filter.applyHoleDistortion(image, completion: { (filteredImage, name) -> Void in
                if let filtered = filteredImage {
                    imageArray.append(filtered)
                }
            })
            
            completion(images: imageArray)
        }
    }
    
//    func displayFilterActionSheet() {
//        if let image = self.imageView.image {
//            let alertController = UIAlertController(title: "Filter", message: "Pick a wacky filter.", preferredStyle: .ActionSheet)
//            
//            let ghostifyAction = UIAlertAction(title: "Ghostify", style: .Default, handler: { (alert) -> Void in
//                Filter.applyGhostFilter(image, completion: { (filteredImage, name) -> Void in
//                    if let filteredImage = filteredImage {
//                        self.imageView.image = filteredImage
//                    }
//                })
//            })
//            let crossProcessAction = UIAlertAction(title: "Cross Process", style: .Default, handler: { (alert) -> Void in
//                Filter.applyProcessFilter(image, completion: { (filteredImage, name) -> Void in
//                    if let filteredImage = filteredImage {
//                        self.imageView.image = filteredImage
//                    }
//                })
//            })
//            let edgesAction = UIAlertAction(title: "Edges", style: .Default, handler: { (alert) -> Void in
//                Filter.applyEdgesFilter(image, completion: { (filteredImage, name) -> Void in
//                    if let filteredImage = filteredImage {
//                        self.imageView.image = filteredImage
//                    }
//                })
//            })
//            let crystallizeAction = UIAlertAction(title: "Crystallize", style: .Default, handler: { (alert) -> Void in
//                Filter.applyCrystallizeFilter(image, completion: { (filteredImage, name) -> Void in
//                    if let filteredImage = filteredImage {
//                        self.imageView.image = filteredImage
//                    }
//                })
//            })
//            let glassLozengeAction = UIAlertAction(title: "Glass Lozenge", style: .Default, handler: { (alert) -> Void in
//                Filter.applyGlassLozengeFilter(image, completion: { (filteredImage, name) -> Void in
//                    if let filteredImage = filteredImage {
//                        self.imageView.image = filteredImage
//                    }
//                })
//            })
//            let lenticularHaloAction = UIAlertAction(title: "Lenticular Halo", style: .Default, handler: { (alert) -> Void in
//                Filter.applyLenticularHalo(image, completion: { (filteredImage, name) -> Void in
//                    if let filteredImage = filteredImage, existingImage = self.imageView.image {
//                        Filter.blendHalo(filteredImage, backgroundImage: existingImage, completion: { (filteredImage, name) -> Void in
//                            if let filteredImage = filteredImage {
//                                self.imageView.image = filteredImage
//                            }
//                        })
//                    }
//                })
//            })
//            let bumpDistortionAction = UIAlertAction(title: "Bump Distortion", style: .Default, handler: { (alert) -> Void in
//                Filter.applyBumpDistortionLinear(image, completion: { (filteredImage, name) -> Void in
//                    if let filteredImage = filteredImage {
//                        self.imageView.image = filteredImage
//                    }
//                })
//            })
//            let holeDistortionAction = UIAlertAction(title: "Hole Distortion", style: .Default, handler: { (alert) -> Void in
//                Filter.applyHoleDistortion(image, completion: { (filteredImage, name) -> Void in
//                    if let filteredImage = filteredImage {
//                        self.imageView.image = filteredImage
//                    }
//                })
//            })
//            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
//            alertController.addAction(ghostifyAction)
//            alertController.addAction(crossProcessAction)
//            alertController.addAction(edgesAction)
//            alertController.addAction(crystallizeAction)
//            alertController.addAction(glassLozengeAction)
//            alertController.addAction(lenticularHaloAction)
//            alertController.addAction(bumpDistortionAction)
//            alertController.addAction(holeDistortionAction)
//            alertController.addAction(cancelAction)
//            self.presentViewController(alertController, animated: true, completion: nil)
//        }
//    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePickerController.delegate = self
        statusMessageTextField.delegate = self
        filterCollectionView.delegate = self
        filterCollectionView.dataSource = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if self.imageView.image == nil {
            self.imageView.image = self.defaultImage
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        let resizedImage = UIImage.resizeImage(image, size: kImagePreferredSize)
        self.imageView.image = resizedImage
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.filteredImages.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kFilterCollectionViewCellIdentifier, forIndexPath: indexPath) as! FilterCollectionViewCell
        cell.filteredImage = self.filteredImages[indexPath.row]
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let size = collectionView.frame.height
        return CGSize(width: size, height: size)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
