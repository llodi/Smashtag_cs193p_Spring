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
    
    var ratio = 0.0
    
    var imageVar: UIImage? {
        get {
            return imageField.image
        }
        
        set {
            imageField.image = newValue
            //imageField.image.
            //imageField.sizeThatFits(
             //   CGSize(width: (newValue?.size.width)! * CGFloat(ratio), height: (newValue?.size.height)! * CGFloat(ratio))
            //)
        }
    }

}
