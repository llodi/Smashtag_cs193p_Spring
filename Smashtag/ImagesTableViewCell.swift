//
//  ImagesTableViewCell.swift
//  Smashtag
//
//  Created by Ilya Dolgopolov on 28.06.16.
//  Copyright © 2016 Ilya Dolgopolov. All rights reserved.
//

import UIKit

class ImagesTableViewCell: UITableViewCell {

    @IBOutlet weak var imageField: UIImageView!
    
    var url: NSURL? {
        didSet {            
            fetchImage()
        }
    }
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var ratio = 0.0
    
    var imageVar: UIImage? {
        get {
            return imageField.image
        }
        
        set {
            imageField.image = newValue
            spinner.stopAnimating()
        }
    }
    
    
    private func fetchImage () {
        if let u = url {
            spinner?.startAnimating()
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
                let contentsOfURL = NSData(contentsOfURL: u)
                dispatch_async(dispatch_get_main_queue()) {
                    if u == self.url {
                        if let imageData = contentsOfURL {
                            self.imageVar = UIImage(data: imageData)
                        } else {
                            self.spinner.stopAnimating()
                        }
                    }
                }
            }
        }
    }
}
