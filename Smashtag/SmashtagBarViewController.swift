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
    
    var clickedItemOld: UITabBarItem?
    
    var clickedItem: UITabBarItem? {
        didSet {
            clickedItemOld = oldValue
        }
    }
    
    override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        clickedItem = item
    }
    
 
    // UITabBarControllerDelegate
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        
        if tabBarController.tabBar.selectedItem == clickedItemOld ?? tabBarController.tabBar.selectedItem {
            if let navcon = viewController as? UINavigationController {
                if let vc = navcon.visibleViewController as? UITableViewController {
                    vc.tableView.scrollRectToVisible(vc.tableView.frame, animated: true)
                }
                
                if let vc = navcon.visibleViewController as? UICollectionViewController {
                    vc.collectionView?.scrollRectToVisible(vc.collectionView!.frame, animated: true)
                }
            }
        }
    }
}
