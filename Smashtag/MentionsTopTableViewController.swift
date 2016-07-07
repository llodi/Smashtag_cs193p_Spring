//
//  MentionsTopTableViewController.swift
//  Smashtag
//
//  Created by Ilya Dolgopolov on 07/07/16.
//  Copyright © 2016 Ilya Dolgopolov. All rights reserved.
//

import UIKit
import CoreData

class MentionsTopTableViewController: CoreDataTableViewController {
    
    var mention: String? { didSet { updateUI() } }
    
    var managedObjectContext: NSManagedObjectContext? { didSet { updateUI() } }
    
    private func updateUI() {
        
    }
 
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TopMetionsList", forIndexPath: indexPath)

        cell.textLabel?.text = "test"

        return cell
    }
    
}
