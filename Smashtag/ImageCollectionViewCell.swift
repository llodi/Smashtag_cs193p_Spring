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
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
                let contentsOfURL = NSData(contentsOfURL: u)
                dispatch_async(dispatch_get_main_queue()) {
                    if u == self.imageURL {
                        if let imageData = contentsOfURL {
                            self.image = UIImage(data: imageData)
                        } else {
                            self.spinner.stopAnimating()
                        }
                    }
                }
            }
        }
    }
}
