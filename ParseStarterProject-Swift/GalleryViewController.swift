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

class GalleryCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var galleryCollectionView: UICollectionView!
    
    var imageStatuses = [Status]() {
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

    override func viewDidLoad() {
        super.viewDidLoad()
        self.galleryCollectionView.dataSource = self
        self.galleryCollectionView.delegate = self
        self.galleryCollectionView.backgroundColor = UIColor.chartreuseColor()
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: "pinch:")
        view.addGestureRecognizer(pinchGesture)
    }
    
    override func viewWillAppear(animated: Bool) {
        fetchStatuses()
    }
    
    func pinch(sender: UIPinchGestureRecognizer) {
        if let _ = sender.view {
            
            self.collectionViewCellScale = self.collectionViewCellScale / sender.scale
        sender.scale = 1.0
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func fetchStatuses() {
        ParseAPI.fetchPosts { (objects) -> () in
            if let statusArray = objects {
                self.imageStatuses = statusArray
            } else {
                let retryAlertController = UIAlertController(title: "Error", message: "Unable to load images.  Please retry.", preferredStyle: .Alert)
                let retryAction = UIAlertAction(title: "Retry", style: .Default, handler: { (action) -> Void in
                    self.fetchStatuses()
                })
                let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
                retryAlertController.addAction(retryAction)
                retryAlertController.addAction(cancelAction)
                self.presentViewController(retryAlertController, animated: true, completion: nil)
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imageStatuses.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kGalleryCollectionViewCellIdentifier, forIndexPath: indexPath) as! GalleryCollectionViewCell
        cell.status = self.imageStatuses[indexPath.row]
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
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
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
}
