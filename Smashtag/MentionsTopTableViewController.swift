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
    private var mentionsManagedObjectContext: NSManagedObjectContext? = (UIApplication.sharedApplication().delegate as? AppDelegate)?.mentionsManagedObjectContext{ didSet { updateUI() } }
    
    private func updateUI() {
        statistics ()
        if let context = mentionsManagedObjectContext where mention?.characters.count > 0  {
            Mention.mentionCountWithMention(inManagedObjectContext: context, withPredicate: mention!)
            let request = NSFetchRequest(entityName: "Mention")
            request.predicate = NSPredicate(format: "any tweets.text contains %@", mention!)
            request.sortDescriptors = [NSSortDescriptor(
                key: "count",
                ascending: false,
                selector: #selector(NSString.localizedCaseInsensitiveCompare(_:))
                ), NSSortDescriptor(
                key: "text",
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
    
    private func statistics () {
        if let context = mentionsManagedObjectContext where mention?.characters.count > 0  {
            let request = NSFetchRequest(entityName: "Mention")
            request.predicate = NSPredicate(format: "any tweets.text contains %@", mention!)
            context.performBlockAndWait{
                if let res = try? context.executeFetchRequest(request) {
                    print ("\(res.count) records returned")
                }
            }
        }
    }
 
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("mentionItem", forIndexPath: indexPath)
        
        if let mention = fetchedResultsController?.objectAtIndexPath(indexPath) as? Mention {
            var text: String?
            
            mention.managedObjectContext?.performBlockAndWait{
                text = mention.text
            }
            cell.textLabel?.text = text
            if let count = mention.count
            {
                cell.detailTextLabel?.text = (count == 1) ? "1 tweet" : "\(count) tweets"
            } else {
                cell.detailTextLabel?.text = ""
            }
        }

        return cell
    }
    
}
