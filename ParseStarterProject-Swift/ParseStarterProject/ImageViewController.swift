//
//  ImageViewController.swift
//  InstaGlam
//
//  Created by Miles Ranisavljevic on 11/2/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import Parse
import Photos

class ImageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, GalleryCollectionViewControllerDelegate, UITabBarControllerDelegate {
    
    let imagePickerController = UIImagePickerController()
    
    let defaultImage = UIImage(named: "Logo")
    
    var filteredImages = [UIImage]() {
        didSet {
            self.filterCollectionView.reloadData()
        }
    }
    
    var filterLabels = [String]()
    
    var photoCollection: PHFetchResult? {
        didSet {
            print("Here's the collection I have: \(photoCollection)")
        }
    }
//
    var folder: PHAssetCollection? {
        didSet {
            print("Is this a collection? \(folder)")
        }
    }

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var statusMessageTextField: UITextField!
    @IBOutlet weak var filterCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePickerController.delegate = self
        statusMessageTextField.delegate = self
        filterCollectionView.delegate = self
        filterCollectionView.dataSource = self
        filterCollectionView.hidden = true
        self.tabBarController?.delegate = self
        getInstaGlamPhotoFolder()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if self.imageView.image == nil {
            self.imageView.backgroundColor = UIColor.lightGreyImageBackgroundColor()
            self.imageView.image = self.defaultImage
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
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
//            if let image = image {
//                let PHPhoto = PHAssetChangeRequest.creationRequestForAssetFromImage(image)
//                if let image = PHPhoto as? PHAsset {
//                    if let collection = self.photoCollection as? PHAssetCollection {
//                        let changeRequest = PHAssetCollectionChangeRequest(forAssetCollection: collection)
//                        changeRequest?.addAssets(image)
//                    }
//                }
//            }
//            Save to local folder
//            PHPhotoLibrary.sharedPhotoLibrary().performChanges({ () -> Void in
//                if let image = image {
//                    PHAssetChangeRequest.creationRequestForAssetFromImage(image)
//                }
//                    }, completionHandler: { (created, error) -> Void in
//                        print("There's a photo now")
//                })
            
            
            if let message = statusMessageTextField.text {
                if message != "" {
                    let statusPost = Status(statusImage: image, statusUpdate: message)
                    ParseAPI.savePost(statusPost, completion: { (saved, error) -> () in
                        if saved {
                            let savedAction = UIAlertController(title: "Saved", message: "Saved successfully!", preferredStyle: .Alert)
                            savedAction.addAction(okAction)
                            self.presentViewController(savedAction, animated: true, completion: { () -> Void in
                                self.imageView.image = self.defaultImage
                                self.imageView.backgroundColor = UIColor.lightGreyImageBackgroundColor()
                                self.statusMessageTextField.text = ""
                                self.statusMessageTextField.placeholder = "Bowl cut, baby!"
                                self.filterCollectionView.hidden = true
                            })
                        } else {
                            if let error = error {
                                let errorAction = UIAlertController(title: "Error!", message: "Error code: \(error.code)", preferredStyle: .Alert)
                                errorAction.addAction(okAction)
                                self.presentViewController(errorAction, animated: true, completion: nil)
                            }
                        }
//                        PHPhotoLibrary - save images to InstaGlam folder
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
        applyFilters()
    }
    
//    func savePhotosToLocalFolder() {
//        let assetCollectionFetch = PHAssetCollection.fetchAssetCollectionsWithLocalIdentifiers(kImageLocalFolderName, options: nil)
//        self.photoCollection = assetCollectionFetch
//        if let collection = self.photoCollection?.firstObject {
//            print(collection)
//        } else {
//            createLocalPhotoFolder()
//        }
//    }
//    
    func createLocalPhotoFolder() {
        if let _ = self.photoCollection {
            print("There's a collection already!")
        } else {
            if let folderName = kImageLocalFolderName.first {
                PHPhotoLibrary.sharedPhotoLibrary().performChanges({ () -> Void in
                    PHAssetCollectionChangeRequest.creationRequestForAssetCollectionWithTitle(folderName)
                    }, completionHandler: { (done, error) -> Void in
                        if let error = error {
                            print("The collection couldn't be created because of: \(error)")
                        }
                        if done == true {
                            print("A collection was created.")
                            self.getInstaGlamPhotoFolder()
                        }
                })
            }
        }
    }
    
    func getInstaGlamPhotoFolder() {
        let options = PHFetchOptions()
        let allCollections = PHAssetCollection.fetchAssetCollectionsWithType(PHAssetCollectionType.Album, subtype: PHAssetCollectionSubtype.AlbumRegular, options: options)
        var identifiers = [String]()
        print("Total count: \(allCollections.count)")
        if let identifier = allCollections.lastObject?.localIdentifier {
            if let plistPath = NSBundle.mainBundle().pathForResource("folder", ofType: "plist") {
                if let plist = NSDictionary(contentsOfFile: plistPath) as? [String : AnyObject] {
                    var plistChange = plist
                    plistChange[kInfoPlistFolderName] = identifier
                    
                }
            }
            identifiers.append(identifier)
            let fetchResults = PHAssetCollection.fetchAssetCollectionsWithLocalIdentifiers(identifiers, options: options)
            if let collection = fetchResults.firstObject as? PHAssetCollection {
                self.folder = collection
            } else {
                createLocalPhotoFolder()
            }
        } else {
            createLocalPhotoFolder()
        }
        
    }
    
    func applyFilters() {
        displayFilterOptions { (images, names) -> () in
            self.filteredImages = images
            self.filterLabels = names
            self.filterCollectionView.hidden = false
        }
    }
    
    func displayFilterOptions(completion: (images: [UIImage], names: [String]) -> ()) {
        var imageArray = [UIImage]()
        var nameArray = [String]()
        if let image = self.imageView.image {
            
            Filter.applyGhostFilter(image, completion: { (filteredImage, name) -> Void in
                if let filtered = filteredImage {
                    imageArray.append(filtered)
                    nameArray.append(name)
                }
            })
            
            Filter.applyProcessFilter(image, completion: { (filteredImage, name) -> Void in
                if let filtered = filteredImage {
                    imageArray.append(filtered)
                    nameArray.append(name)
                }
            })
            
            Filter.applyEdgesFilter(image, completion: { (filteredImage, name) -> Void in
                if let filtered = filteredImage {
                    imageArray.append(filtered)
                    nameArray.append(name)
                }
            })
            
            Filter.applyCrystallizeFilter(image, completion: { (filteredImage, name) -> Void in
                if let filtered = filteredImage {
                    imageArray.append(filtered)
                    nameArray.append(name)
                }
            })
            
            Filter.applyGlassLozengeFilter(image, completion: { (filteredImage, name) -> Void in
                if let filtered = filteredImage {
                    imageArray.append(filtered)
                    nameArray.append(name)
                }
            })
            
            Filter.applyLenticularHalo(image, completion: { (filteredImage, name) -> Void in
                if let filteredImage = filteredImage {
                    Filter.blendHalo(filteredImage, backgroundImage: image, completion: { (filteredImage, name) -> Void in
                        if let filtered = filteredImage {
                            imageArray.append(filtered)
                        }
                    })
                    nameArray.append(name)
                }
            })
            
            Filter.applyBumpDistortionLinear(image, completion: { (filteredImage, name) -> Void in
                if let filtered = filteredImage {
                    imageArray.append(filtered)
                    nameArray.append(name)
                }
            })
            
            Filter.applyHoleDistortion(image, completion: { (filteredImage, name) -> Void in
                if let filtered = filteredImage {
                    imageArray.append(filtered)
                    nameArray.append(name)
                }
            })
            
            completion(images: imageArray, names: nameArray)
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        let resizedImage = UIImage.resizeImage(image, size: kImagePreferredSize)
        self.imageView.backgroundColor = UIColor.blackColor()
        self.imageView.image = resizedImage
        self.filterCollectionView.hidden = true
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.filteredImages.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kFilterCollectionViewCellIdentifier, forIndexPath: indexPath) as! FilterCollectionViewCell
        cell.filteredImage = self.filteredImages[indexPath.row]
        cell.filterName = self.filterLabels[indexPath.row]
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let size = collectionView.frame.height
        return CGSize(width: size, height: size)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.imageView.backgroundColor = UIColor.blackColor()
        self.imageView.image = filteredImages[indexPath.row]
        applyFilters()
    }
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        if let viewController = viewController as? GalleryCollectionViewController {
            viewController.delegate = self
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func didSelectItemInGalleryWithImage(image: UIImage) {
        self.imageView.backgroundColor = UIColor.blackColor()
        self.imageView.image = image
        self.statusMessageTextField.placeholder = "Bring the bowl cut back!"
    }
    
}
