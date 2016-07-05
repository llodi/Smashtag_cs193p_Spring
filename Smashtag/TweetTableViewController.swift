//
//  TweetTableViewController.swift
//  Shashtag
//
//  Created by Ilya Dolgopolov on 25.06.16.
//  Copyright © 2016 Ilya Dolgopolov. All rights reserved.
//

import UIKit
import Twitter
import CoreData

class TweetTableViewController: UITableViewController, UITextFieldDelegate {
   
    var tweets = [Array<Twitter.Tweet>]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    var managedObjectContext: NSManagedObjectContext? = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext

    
    //переменная поисковая строка
    var searchText: String? {
        didSet {
            lastTwitterRequest = nil
            tweets.removeAll()
            searchForTweets()
            self.navigationItem.title = searchText
        }
    }
    
    //запрос твитов
    //
    private var twitterRequest: Twitter.Request? {
        if lastTwitterRequest == nil {
            if let query = searchText where !query.isEmpty {
                return Twitter.Request(search: query + " -filter:retweets", count: 100)
            }
        }
        return lastTwitterRequest?.requestForNewer
    }
    
    /*прошлый запрос: те если вы запрашиваете твиты,
     они еще не загрузились, и вы пустили новый запрос,
     
     */
    private var lastTwitterRequest: Twitter.Request?
    
    
    private func searchForTweets () {
        if let request = twitterRequest {
            TweetsTracking.Tracking.add(searchText!)
            lastTwitterRequest = request
            request.fetchTweets{ [weak weakSelf = self] newTweets in
                dispatch_async(dispatch_get_main_queue()) {
                    if request == weakSelf?.lastTwitterRequest {
                        if !newTweets.isEmpty {
                            weakSelf?.tweets.insert(newTweets, atIndex: 0)
                            weakSelf?.updateDatabase(newTweets)
                        }
                    }
                    weakSelf?.refreshControl?.endRefreshing()
                }
            }
        } else {
            refreshControl?.endRefreshing()
        }
    }
    
    private func updateDatabase(newTweets: [Twitter.Tweet]) {
        managedObjectContext?.performBlock {
            for twitterInfo in newTweets {
                _ = Tweet.tweetWithTwitterInfo(twitterInfo, inManagedObjectContext: self.managedObjectContext!)
            }
            do {
                try self.managedObjectContext?.save()
            } catch let error {
                print("Core Data Error: \(error)")
            }
        }
        printDatabaseStatistics()	
        print("Print Staticstics Done!")
    }
    
    private func printDatabaseStatistics() {
        managedObjectContext?.performBlock{
            if let result = try? self.managedObjectContext!.executeFetchRequest(NSFetchRequest(entityName: "TweeterUser")) {
                print("\(result.count) TweeterUser")
            }
            let tweetCount = self.managedObjectContext!.countForFetchRequest(NSFetchRequest(entityName: "Tweet"), error: nil)
            print("\(tweetCount) tweets")
        }
    }
 
    @IBAction func refreshTweets(sender: UIRefreshControl?) {
        searchForTweets()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //динамическая высота полей
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight  = UITableViewAutomaticDimension
    }
    
    // MARK: - UITableViewDataSource
    //количество секций в TableView равно кол-ву твитов в массиве
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return tweets.count
    }

    //кол-во строк в секции равно кол-ву элементов в одном твитте
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets[section].count
    }
    
    //константы
    private struct Storyboard {
        static let TweetCellIdentifier = "Tweet"
        static let DetailedSequeIdentifier = "Detailed Tweet"
        static let TweetersMentioningSearchTermSegue = "TweetersMentioningSearchTerm"
    }
    
    //релизация показа данных для каждого элемента
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.TweetCellIdentifier, forIndexPath: indexPath)
        let tweet = tweets[indexPath.section][indexPath.row]
        if let tweetCell = cell as? TweetTableViewCell {
            tweetCell.tweet = tweet
        }
        return cell
    }
    
    //работа с поисковой строкой
    @IBOutlet weak var searchTextField: UITextField! {
        didSet {
            searchTextField.delegate = self
            searchTextField.text = searchText
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        searchText = textField.text
        return true
    }
    
   
    private func getMentionsArray(t: Twitter.Tweet) -> ([Array<AnyObject>],[String]){
        var mentions = [Array<AnyObject>] ()
        var mentionType: [String] = []
        
        if t.media.count > 0 {
            mentions.append(t.media)
            mentionType.append("Images")
        }
        if t.hashtags.count > 0 {
            mentions.append(t.hashtags)
            mentionType.append("Hashtags")
        }
        if t.userMentions.count > 0 {
            mentions.append(t.userMentions)
            mentionType.append("Users")
        }
        if t.urls.count > 0 {
            mentions.append(t.urls)
            mentionType.append("Urls")
        }
        return (mentions,mentionType)
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Storyboard.DetailedSequeIdentifier {
            if let dttvc = segue.destinationViewController as? DetailedTweetTableViewController {
                if let tweetCell = (sender as? TweetTableViewCell) {
                    if let tweet = tweetCell.tweet {
                        //(dttvc.mentions, dttvc.mentionType)
                        let m = getMentionsArray(tweet)
                        dttvc.mentions = m.0
                        dttvc.mentionType = m.1
                        dttvc.title = tweet.user.name
                    }
                }
            }
        }
        if segue.identifier == Storyboard.TweetersMentioningSearchTermSegue {
            if let tTVC = segue.destinationViewController as? TweetersTableViewController {
                tTVC.mention = searchText
                tTVC.managedObjectContext = managedObjectContext
            }
        }
    }
}


