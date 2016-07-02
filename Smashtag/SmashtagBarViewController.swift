//
//  SmashtagBarViewController.swift
//  Smashtag
//
//  Created by Ilya Dolgopolov on 02.07.16.
//  Copyright © 2016 Ilya Dolgopolov. All rights reserved.
//

import UIKit

class SmashtagBarViewController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
    
    // UITabBarControllerDelegate
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        if let navcon = viewController as? UINavigationController {
            if let vc = navcon.visibleViewController as? UITableViewController {
                vc.tableView.setContentOffset(CGPointZero, animated: true)
            }
        }
    }
}
