//
//  TweetersTableViewController.swift
//  Smashtag
//
//  Created by Ilya Dolgopolov on 03.07.16.
//  Copyright © 2016 Ilya Dolgopolov. All rights reserved.
//

import UIKit
import CoreData

class TweetersTableViewController: CoreDataTableViewController {

    var mention: String? { didSet { updateUI() } }
    
    var managedObjectContext: NSManagedObjectContext? { didSet { updateUI() } }
    
    
    private func updateUI() {
        if let context = managedObjectContext where mention?.characters.count > 0 {
            let request = NSFetchRequest(entityName: "TweeterUser")
            request.predicate = NSPredicate(format: "any tweets.text contains[c] %@ and !screenName beginswith[c] %@", mention!, "darkside")
            request.sortDescriptors = [NSSortDescriptor(
                key: "screenName",
                ascending: true,
                selector: #selector(NSString.localizedCaseInsensitiveCompare(_:))
                )]
            fetchedResultsController = NSFetchedResultsController(
                fetchRequest: request,
                managedObjectContext: context,
                sectionNameKeyPath: nil,
                cacheName: nil
             )
        } else {
            fetchedResultsController = nil
        }
    }
    
    private func tweetCountWithMentionByTweeterUser(user: TweeterUser) -> Int? {
        var count: Int?
        
        user.managedObjectContext?.performBlockAndWait{
            let request = NSFetchRequest(entityName: "Tweet")
            request.predicate = NSPredicate(format: "text contains[c] %@ and tweeter = %@", self.mention!, user)
            count = user.managedObjectContext?.countForFetchRequest(request, error: nil)            
        }
        return count
    }
    

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TwitterUserCell", forIndexPath: indexPath)
        
        if let tweeterUser = fetchedResultsController?.objectAtIndexPath(indexPath) as? TweeterUser {
            var screenName: String?
            tweeterUser.managedObjectContext?.performBlockAndWait {
                screenName = tweeterUser.screenName
            }
            cell.textLabel?.text = screenName
            if let count = tweetCountWithMentionByTweeterUser(tweeterUser)
            {
                cell.detailTextLabel?.text = (count == 1) ? "1 tweet" : "\(count) tweets"
            } else {
                cell.detailTextLabel?.text = ""
            }
        }

        return cell
    }


}
