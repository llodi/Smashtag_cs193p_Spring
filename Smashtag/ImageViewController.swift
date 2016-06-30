//
//  ImageViewController.swift
//  Smashtag
//
//  Created by Ilya Dolgopolov on 30/06/16.
//  Copyright © 2016 Ilya Dolgopolov. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.contentSize = imageView.frame.size
            scrollView.delegate = self
            scrollView.minimumZoomScale = 0.03
            scrollView.maximumZoomScale = 1.0
        }
    }
    
    var ratio = 0.0
    
    private func zoomToScale () {
        //view.bounds.size
        let widthRatioHor = view.bounds.size.width / imageView.bounds.size.width
        let heightRatioHor = view.bounds.size.height / imageView.bounds.size.height
        
        let widthRatioVer = imageView.bounds.size.width / view.bounds.size.width
        let heightRatioVer = imageView.bounds.size.height / view.bounds.size.height
        
        var scale: CGFloat = 0.0
        
        if view.bounds.size.width > view.bounds.size.height {
            scale = widthRatioHor / heightRatioHor
        } else {
            scale = heightRatioVer / widthRatioVer
        }
        
        scrollView.setZoomScale(scale, animated: true)
        
        //let height = scrollView.bounds.size.width / CGFloat(ratio)
        //scrollView.setZoomScale(height, animated: true)
    }
    
    @IBAction func tapToAutoZoom(sender: UITapGestureRecognizer) {
        switch sender.state {
        case .Ended: zoomToScale()
        default: break
        }
    }
    
    private var imageView = UIImageView()
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.image = newValue
            imageView.sizeToFit()
            scrollView?.contentSize = imageView.frame.size
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.addSubview(imageView)
    }
    
}
