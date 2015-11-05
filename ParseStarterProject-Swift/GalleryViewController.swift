//
//  TimelineViewController.swift
//  InstaGlam
//
//  Created by Miles Ranisavljevic on 11/2/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit

class GalleryCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var galleryCollectionView: UICollectionView!
    
    var imageStatuses = [Status]() {
        didSet {
            self.galleryCollectionView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.galleryCollectionView.dataSource = self
        self.galleryCollectionView.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        fetchStatuses()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func fetchStatuses() {
        var statuses = [Status]()
        ParseAPI.fetchPosts { (objects) -> () in
            if let objects = objects {
                var i = 0
            for object in objects {
                ParseAPI.convertPFObjectToStatus(object, completion: { (status, error) -> () in
                    if error == false {
                        if let convertedStatus = status {
                            statuses.append(convertedStatus)
                            i++
                            if i == objects.count {
                                self.imageStatuses = statuses
                            }
                        }
                    } else {
                        print("error")
                    }
                })
                }
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
        let cellEdgeSize = (frameWidth / 2.0) - 2.0
        return CGSizeMake(cellEdgeSize, cellEdgeSize)
    }
}
