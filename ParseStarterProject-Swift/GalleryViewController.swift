//
//  TimelineViewController.swift
//  InstaGlam
//
//  Created by Miles Ranisavljevic on 11/2/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit

protocol GalleryCollectionViewControllerDelegate {
    func didSelectItemInGalleryWithImage(image: UIImage)
}

class GalleryCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITabBarControllerDelegate, GalleryCollectionViewHeaderDelegate {
    
    @IBOutlet weak var galleryCollectionView: UICollectionView!
    
    var imageStatuses = [Status]() {
        didSet {
            self.galleryCollectionView.reloadData()
        }
    }
    
    var localInstaGlamImages = [UIImage]()
    
    var activeGallery = "Cloud Gallery" {
        didSet {
            self.galleryCollectionView.reloadData()
        }
    }
    
    var collectionViewCellScale = CGFloat(3.0) {
        didSet {
            self.galleryCollectionView.reloadData()
        }
    }
    
    var delegate: GalleryCollectionViewControllerDelegate?
    
    //MARK: Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        self.galleryCollectionView.dataSource = self
        self.galleryCollectionView.delegate = self
        self.galleryCollectionView.backgroundColor = UIColor.chartreuseColor()
        self.tabBarController?.delegate = self
        self.tabBarController?.tabBarItem.title = ""
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: "pinch:")
        view.addGestureRecognizer(pinchGesture)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        fetchParseStatuses()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: Gesture Recognizer Setup
    
    func pinch(sender: UIPinchGestureRecognizer) {
        if let _ = sender.view {
            let newScale = self.collectionViewCellScale / sender.scale
            if newScale >= 1.01 && newScale <= 86.0 {
                self.collectionViewCellScale = newScale
            }
        sender.scale = 1.0
        }
    }
    
    //MARK: Parse Functions
    
    func fetchParseStatuses() {
        ParseAPI.fetchPosts { (objects) -> () in
            if let statusArray = objects {
                self.imageStatuses = statusArray
                self.activeGallery = "Cloud Gallery"
            } else {
                let retryAlertController = UIAlertController(title: "Error", message: "Unable to load images.  Please retry.", preferredStyle: .Alert)
                let retryAction = UIAlertAction(title: "Retry", style: .Default, handler: { (action) -> Void in
                    self.fetchParseStatuses()
                })
                let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
                retryAlertController.addAction(retryAction)
                retryAlertController.addAction(cancelAction)
                self.presentViewController(retryAlertController, animated: true, completion: nil)
            }
        }
    }
    
    //MARK: CollectionView Delegate/Datasource/FlowLayout Methods
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var itemCount = 0
        if self.activeGallery == "Cloud Gallery" {
            itemCount = self.imageStatuses.count
        } else {
            itemCount = self.localInstaGlamImages.count
        }
        return itemCount
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kGalleryCollectionViewCellIdentifier, forIndexPath: indexPath) as! GalleryCollectionViewCell
        if self.activeGallery == "Cloud Gallery" {
            cell.status = self.imageStatuses[indexPath.row]
            if self.collectionViewCellScale <= 1.1 {
                cell.cellStatusMessageLabel.text = self.imageStatuses[indexPath.row].statusUpdate
            } else {
                cell.cellStatusMessageLabel.text = ""
            }
        } else {
            cell.status = nil
            cell.image = self.localInstaGlamImages[indexPath.row]
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let viewSize = self.view.frame
        let frameWidth = viewSize.width
        let cellEdgeSize = (frameWidth / collectionViewCellScale) - 3.0
        return CGSizeMake(cellEdgeSize, cellEdgeSize)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(2.0, 2.0, 2.0, 2.0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 2.0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 2.0
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let image = imageStatuses[indexPath.row].statusImageFile
        image?.getDataInBackgroundWithBlock({ (data, error) -> Void in
            if error != nil {
                print("Your photo didn't come back with code \(error!.code)")
            }
            if let imageData = data {
                if let image = UIImage(data: imageData) {
                    if let delegate = self.delegate {
                        delegate.didSelectItemInGalleryWithImage(image)
                    }
                }
            }
        })
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: kGalleryCollectionViewHeaderIdentifier, forIndexPath: indexPath) as! GalleryCollectionViewHeader
        header.galleryHeaderTitleLabel.text = self.activeGallery
        header.delegate = self
        return header
    }
    
    //MARK: GalleryCollectionViewHeader Delegate Methods
    
    func didChangeGallerySource(source: String) {
        self.activeGallery = source
    }
    
}
