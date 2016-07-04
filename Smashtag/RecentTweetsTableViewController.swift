//
//  RecentTweetsTableViewController.swift
//  Smashtag
//
//  Created by Ilya Dolgopolov on 01.07.16.
//  Copyright © 2016 Ilya Dolgopolov. All rights reserved.
//

import UIKit

class RecentTweetsTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        if TweetsTracking.Tracking.values.count > 0 {
        //    let editButton = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: #selector(RecentTweetsTableViewController.edit(_:)))
            //navigationItem.rightBarButtonItem = editButton
            self.navigationItem.rightBarButtonItem = self.editButtonItem()
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    private struct Storyboard {
        static let cellIdentifier = "Recent"
        static let segueIdentifier = "Show Recent Result"
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return TweetsTracking.Tracking.values.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.cellIdentifier, forIndexPath: indexPath)
        cell.textLabel?.text = TweetsTracking.Tracking.values[indexPath.row]
        
        return cell
    }
 

    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
 

    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            TweetsTracking.Tracking.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    

    
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
        let tw = TweetsTracking.Tracking.values.removeAtIndex(fromIndexPath.row)
        TweetsTracking.Tracking.values.insert(tw, atIndex: toIndexPath.row)
    }
    

    
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    
    

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Storyboard.segueIdentifier {
            if let tvc = segue.destinationViewController as? TweetTableViewController {
                if let cell = sender as? UITableViewCell {
                    tvc.searchText = cell.textLabel?.text
                }
            }
        }
    }


}
