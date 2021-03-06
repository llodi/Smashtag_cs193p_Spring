//
//  SearchResultsTableViewController.swift
//  Smashtag
//
//  Created by Ilya Dolgopolov on 30/06/16.
//  Copyright © 2016 Ilya Dolgopolov. All rights reserved.
//

import UIKit
import Twitter

class SearchResultsTableViewController: UITableViewController {
    
    var tweets = [Array<Twitter.Tweet>]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    //переменная поисковая строка
    var searchText: String? {
        didSet {
            lastTwitterRequest = nil
            tweets.removeAll()
            searchForTweets()
            title = searchText
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
     они еще не загрузились, и вы пустили новый запрос     
     */
    private var lastTwitterRequest: Twitter.Request?
    
    
    private func searchForTweets () {
        if let request = twitterRequest {
            lastTwitterRequest = request
            request.fetchTweets{ [weak weakSelf = self] newTweets in
                dispatch_async(dispatch_get_main_queue()) {
                    if request == weakSelf?.lastTwitterRequest {
                        if !newTweets.isEmpty {
                            weakSelf?.tweets.insert(newTweets, atIndex: 0)
                        }
                    }
                    weakSelf?.refreshControl?.endRefreshing()
                }
            }
        } else {
            refreshControl?.endRefreshing()
        }
    }
    
    @IBAction func refreshTweets(sender: UIRefreshControl?) {
        searchForTweets()
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
        static let TweetCellIdentifier = "Searched Tweets"
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
