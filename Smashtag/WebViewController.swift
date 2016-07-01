//
//  WebViewController.swift
//  Smashtag
//
//  Created by Ilya Dolgopolov on 01/07/16.
//  Copyright © 2016 Ilya Dolgopolov. All rights reserved.
//

import UIKit

class WebViewController: UIViewController, UIWebViewDelegate {
    
    var url: NSURL?
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.delegate = self
        if let actualURL = url {
            let urlRequest = NSURLRequest(URL: actualURL)
            
            webView.scalesPageToFit = true
            webView.allowsInlineMediaPlayback = true
            
            webView.loadRequest(urlRequest)
        }
        
        // добавляем кнопку replay для возврата в Web View
        let backButton = UIBarButtonItem(barButtonSystemItem: .Reply,
                                         target: self,
                                         action: #selector(self.actionGoBack))
        if let button = navigationItem.rightBarButtonItem {
            navigationItem.rightBarButtonItems = [button,backButton]
        } else {
            navigationItem.rightBarButtonItem = backButton
        }
    }
    
    func actionGoBack(sender: UIBarButtonItem) {
        webView.goBack()
    }
    
    func actionToSafari() {
        //webView.go
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        spinner.startAnimating()
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        spinner.stopAnimating() 
    }
}

