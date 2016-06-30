//
//  DetailedTweetTableViewController.swift
//  Smashtag
//
//  Created by Ilya Dolgopolov on 28.06.16.
//  Copyright © 2016 Ilya Dolgopolov. All rights reserved.
//

import UIKit
import Twitter

class DetailedTweetTableViewController: UITableViewController {

    var mentions = [Array<AnyObject>] (){
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //динамическая высота полей
        //tableView.estimatedRowHeight = tableView.rowHeight
        //tableView.rowHeight  = UITableViewAutomaticDimension
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    var mentionType: [String]? {
        didSet {
            tableView.reloadData()
        }
    }
   
    //константы
    private struct Storyboard {
        static let MentionImagesCellIdentifier = "Images"
        static let MentionTextCellIdentifier = "Text"
        static let SearchSegue = "Search Result"
    }


    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return mentions.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print ("rows  \(infoAboutTweet[Array(infoAboutTweet.keys)[section]] ?? 0)")
        return mentions[section].count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let mention = mentions[indexPath.section][indexPath.row]
        if let media = mention as? MediaItem {
            return view.bounds.size.width / CGFloat(media.aspectRatio)
        } else {
            return UITableViewAutomaticDimension
        }
        
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let mention = mentions[indexPath.section][indexPath.row]
        if let media = mention as? MediaItem {
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.MentionImagesCellIdentifier, forIndexPath: indexPath)
            if let imageCell = cell as? ImagesTableViewCell {
                imageCell.url = media.url
            }
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.MentionTextCellIdentifier, forIndexPath: indexPath)
            let textMention = mentions[indexPath.section][indexPath.row]
            if let text = textMention as? Twitter.Mention {
                if let textCell = cell as? TextTableViewCell {
                    textCell.mention = text
                }
            }
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return mentionType?[section]
    }


    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Storyboard.SearchSegue {
            if let svc = segue.destinationViewController as? SearchResultsTableViewController {
                if let cell = sender as? TextTableViewCell {
                    if let text = cell.hashtagLabel.text {
                        if text.hasPrefix("@") || text.hasPrefix("#") {
                            svc.searchText = text
                        }
                    }
                }
            } else if let svc = segue.destinationViewController as? ImageViewController {
                if let cell = sender as? ImagesTableViewCell {
                    svc.image = cell.imageVar
                    svc.ratio = cell.ratio
                }
            }
        }
    }


}
