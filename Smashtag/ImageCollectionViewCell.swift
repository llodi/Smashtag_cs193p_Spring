//
//  ImageCollectionViewCell.swift
//  Smashtag
//
//  Created by Ilya Dolgopolov on 02.07.16.
//  Copyright © 2016 Ilya Dolgopolov. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var imageView: UIImageView!
    
    var cache: NSCache?
    var tweetMedia: ImageTweet? {
        didSet {
            imageURL = tweetMedia?.image.url
            fetchImage()
        }
    }
    
    private var imageURL: NSURL?
    private var image: UIImage? {
        get { return imageView.image }
        set {
            imageView.image = newValue
            spinner?.stopAnimating()
        }
    }
    
    private func fetchImage () {
        if let u = imageURL {
            spinner?.startAnimating()
            
            let imageData = cache?.objectForKey(imageURL!) as? NSData
            
            if imageData != nil {
                self.image = UIImage(data: imageData!)
                return
            }
            
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
                let imageData = NSData(contentsOfURL: u)
                dispatch_async(dispatch_get_main_queue()) { [weak weakSelf = self] in
                    if u == weakSelf?.imageURL {
                        if let imageData = imageData {
                            weakSelf?.image = UIImage(data: imageData)
                            weakSelf?.cache?.setObject(imageData, forKey: self.imageURL!, cost: imageData.length / 1024)
                        } else {
                            weakSelf?.image = nil
                            weakSelf?.spinner.stopAnimating()
                        }
                    }
                }
            }
        }
    }
}
