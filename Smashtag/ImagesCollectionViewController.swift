//
//  ImagesCollectionViewController.swift
//  Smashtag
//
//  Created by Ilya Dolgopolov on 02.07.16.
//  Copyright © 2016 Ilya Dolgopolov. All rights reserved.
//

import UIKit
import Twitter



struct ImageTweet {
    var tweet: Tweet
    var image: MediaItem
}


class ImagesCollectionViewController: UICollectionViewController {
    
    private let reuseIdentifier = "Image Cell"
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let first = TweetsTracking.Tracking.values.first {
            searchText = first
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.registerClass(ImageCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }
    
   
    private var cache = NSCache()
    
    private var images: [ImageTweet] = []
    
    var tweets = [Array<Twitter.Tweet>]() {
        didSet {
            images = tweets.flatMap({$0}).map {
                tweet in tweet.media.map{ ImageTweet(tweet: tweet, image: $0)}}.flatMap({$0})
            collectionView?.reloadData()
        }
    }
    
    
    //переменная поисковая строка
    var searchText: String? {
        didSet {
            lastTwitterRequest = nil
            tweets.removeAll()
            searchForTweets()
            //self.navigationItem.title = searchText
        }
    }
    
    //запрос твитов
    //
    private var twitterRequest: Twitter.Request? {
        if lastTwitterRequest == nil {
            if let query = searchText where !query.isEmpty {
                //TweetsTracking.Tracking.add(searchText!)
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
            lastTwitterRequest = request
            dispatch_async (dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
                request.fetchTweets{ [weak weakSelf = self] newTweets in
                    dispatch_async(dispatch_get_main_queue()) {
                        if request == weakSelf?.lastTwitterRequest {
                            if !newTweets.isEmpty {
                                weakSelf?.tweets.insert(newTweets, atIndex: 0)
                            }
                        }
                    }
                }
            }
        }
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return images.count
    }
    
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! ImageCollectionViewCell

        //cell.cache = cache
        cell.tweetMedia = images[indexPath.row]

        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

}
