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
    
    var localInstaGlamPhotoCollection: PHAssetCollection?
    
    var localInstaGlamImages = [UIImage]()
    
    var allLocalPhotoCollections: [PHAssetCollection]?
    
    //MARK: IBOutlets

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var statusMessageTextField: UITextField!
    @IBOutlet weak var filterCollectionView: UICollectionView!
    
    //MARK: Lifecycle Methods
    
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
    
    //MARK: Button IBActions
    
    @IBAction func imagePickerButton(sender: UIButton) {
        displayImagePicker()
    }
    
    @IBAction func saveButtonPressed(sender: UIButton) {
        saveSelectedImage()
            }
    
    @IBAction func filtersButtonPressed(sender: UIButton) {
        applyFilters()
    }
    
    //MARK: Image Section Functions
    
    func displayImagePicker() {
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
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            imagePickerAction.addAction(cameraAction)
            imagePickerAction.addAction(photoLibraryAction)
            imagePickerAction.addAction(cancelAction)
            self.presentViewController(imagePickerAction, animated: true, completion: nil)
        } else {
            self.imagePickerController.sourceType = .PhotoLibrary
            self.presentViewController(self.imagePickerController, animated: true, completion: nil)
        }
    }
    
    func saveSelectedImage() {
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        let image = self.imageView.image
        if image != defaultImage {
            if let message = statusMessageTextField.text {
                if message != "" {
                    let statusPost = Status(statusImage: image, statusUpdate: message)
                    ParseAPI.savePost(statusPost, completion: { (saved, error) -> () in
                        if saved {
                            self.getInstaGlamPhotoFolder()
                            self.savePhotosToLocalFolder(image!)
                            let savedAction = UIAlertController(title: "Saved", message: "Saved successfully!", preferredStyle: .Alert)
                            savedAction.addAction(okAction)
                            self.presentViewController(savedAction, animated: true, completion: { () -> Void in
                                self.imageView.image = self.defaultImage
                                self.imageView.backgroundColor = UIColor.lightGreyImageBackgroundColor()
                                self.statusMessageTextField.text = ""
                                self.statusMessageTextField.placeholder = "Bowl cut, baby!"
                                self.filterCollectionView.hidden = true
                                self.fetchLocalInstaGlamAssets()
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
    
    //MARK: Photos Framework Functions
    
    func getAllPhotoFolders() {
        let options = PHFetchOptions()
        let localCollections = PHAssetCollection.fetchAssetCollectionsWithType(PHAssetCollectionType.Album, subtype: PHAssetCollectionSubtype.Any, options: options)
        localCollections.enumerateObjectsUsingBlock({ (object, index, end) -> Void in
        if let collection = object as? PHAssetCollection {
            self.allLocalPhotoCollections?.append(collection)
            }
        })
    }
    
    func getInstaGlamPhotoFolder() {
        let options = PHFetchOptions()
        let filter: [String] = ["localizedTitle", kImageLocalFolderName]
        options.predicate = NSPredicate(format: "%K like %@", argumentArray: filter)
        let localCollection = PHAssetCollection.fetchAssetCollectionsWithType(PHAssetCollectionType.Album, subtype: PHAssetCollectionSubtype.AlbumRegular, options: options)
        if let collection = localCollection.firstObject as? PHAssetCollection {
            self.localInstaGlamPhotoCollection = collection
            self.fetchLocalInstaGlamAssets()
        } else {
            createLocalPhotoFolder()
        }
    }
    
    func createLocalPhotoFolder() {
        if let _ = self.localInstaGlamPhotoCollection {
        } else {
            let folderName = kImageLocalFolderName
            PHPhotoLibrary.sharedPhotoLibrary().performChanges({ () -> Void in
                PHAssetCollectionChangeRequest.creationRequestForAssetCollectionWithTitle(folderName)
                }, completionHandler: { (done, error) -> Void in
                    if let error = error {
                        print("The collection couldn't be created because of: \(error)")
                    }
                    if done == true {
                        self.getInstaGlamPhotoFolder()
                    }
            })
        }
    }
    
    func savePhotosToLocalFolder(image: UIImage) {
        PHPhotoLibrary.sharedPhotoLibrary().performChanges({ () -> Void in
            let photo = PHAssetChangeRequest.creationRequestForAssetFromImage(image)
            let placeholder = photo.placeholderForCreatedAsset
            if let asset = placeholder {
                let assets: [PHObjectPlaceholder] = [asset]
                if let collection = self.localInstaGlamPhotoCollection {
                    let addAsset = PHAssetCollectionChangeRequest(forAssetCollection: collection)
                    addAsset?.addAssets(assets)
                }
            }
            }, completionHandler: { (created, error) -> Void in
        })
    }
    
    func fetchLocalInstaGlamAssets() {
        let options = PHFetchOptions()
        if let collection = self.localInstaGlamPhotoCollection {
            let assets = PHAsset.fetchAssetsInAssetCollection(collection, options: options)
            if assets.countOfAssetsWithMediaType(PHAssetMediaType.Image) > 0 {
                self.localInstaGlamImages = []
                assets.enumerateObjectsUsingBlock({ (object, index, stop) -> Void in
                    if let asset = object as? PHAsset {
                        PHCachingImageManager.defaultManager().requestImageDataForAsset(asset, options: nil, resultHandler: { (data, dataUTI, orientation, info) -> Void in
                            if let imageData = data {
                                if let image = UIImage(data: imageData) {
                                    self.localInstaGlamImages.append(image)
                                }
                            }
                        })
                    }
                })
            }
        }
    }
    
    //MARK: Filter Functions
    
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
    
    //MARK: ImagePickerController Delegate Methods
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        let resizedImage = UIImage.resizeImage(image, size: kImagePreferredSize)
        self.imageView.backgroundColor = UIColor.blackColor()
        self.imageView.image = resizedImage
        self.filterCollectionView.hidden = true
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: CollectionView Delegate/Datasource/FlowLayout Methods
    
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
    
    //MARK: TabBarController Delegate Methods
    
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        if let viewController = viewController as? GalleryCollectionViewController {
            viewController.delegate = self
            self.getAllPhotoFolders()
            viewController.localInstaGlamImages = self.localInstaGlamImages
        }
        return true
    }
    
    //MARK: TextField Delegate Methods
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: GalleryViewController Delegate Methods
    
    func didSelectItemInGalleryWithImage(image: UIImage) {
        self.imageView.backgroundColor = UIColor.blackColor()
        self.imageView.image = image
        self.statusMessageTextField.placeholder = "Bring the bowl cut back!"
        if let tabBar = self.tabBarController {
            tabBar.selectedIndex = 0
        }
    }
    
}
