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
    var tweet: Twitter.Tweet
    var image: Twitter.MediaItem
}


class ImagesCollectionViewController: UICollectionViewController, CHTCollectionViewDelegateWaterfallLayout  {
    
    private struct Storyboard {
        static let reuseIdentifier = "Image Cell"
        static let segueToTweet = "Show Tweet"
        static let SizeSetting = CGSize(width: 140.0, height: 140.0)
        
        static let ColumnCountWaterfall = 3
        static let minimumColumnSpacing:CGFloat = 2
        static let minimumInteritemSpacing:CGFloat = 2
        
        static let minimumLineSpacing:CGFloat = 2
        static let minimumInteritemSpacingFlow:CGFloat = 2
        static let sectionInset = UIEdgeInsets (top: 2, left: 2, bottom: 2, right: 2)
        static let columnCount:Int = 3
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let first = TweetsTracking.Tracking.values.first {
            searchText = first
        }
        
        // Установка Layout
        setupLayout()
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        //self.collectionView!.registerClass(ImageCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        
        refreshControl.addTarget(self, action: #selector(ImagesCollectionViewController.refreshTweets(_:)), forControlEvents: .ValueChanged)
        
        collectionView?.addSubview(refreshControl)
    }
    
    
    var refreshControl = UIRefreshControl()
    
    func refreshTweets(sender: UIRefreshControl?) {
        if let first = TweetsTracking.Tracking.values.first {
            searchText = first
        }
        searchForTweets()
        refreshControl.endRefreshing()
    }
    
    
    var scale: CGFloat = 1 {
        didSet {
            collectionView?.collectionViewLayout.invalidateLayout()
        }
    }
    
    private var layoutFlow = UICollectionViewFlowLayout()
    private var layoutWaterfall = CHTCollectionViewWaterfallLayout ()
   
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
            self.navigationItem.title = searchText
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



    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Storyboard.segueToTweet {
            if let vc = segue.destinationViewController as? TweetTableViewController {
                if let item = sender as? ImageCollectionViewCell, let media = item.tweetMedia {
                    vc.tweets = [[media.tweet]]
                }
            }
        }
    }
    
    //MARK: - Настройка Layout CollectionView
    private func setupLayout(){
        
        // Меняем атрибуты для WaterfallLayout
        
        // зазоры между ячейками и строками и
        // количество столбцов - основной параметр настройки
        
        layoutWaterfall.columnCount = Storyboard.ColumnCountWaterfall
        layoutWaterfall.minimumColumnSpacing = Storyboard.minimumColumnSpacing
        layoutWaterfall.minimumInteritemSpacing = Storyboard.minimumInteritemSpacing
        
        // Меняем атрибуты для FlowLayout
        // зазоры между ячейками и строками и
        // зазоры для секции
        
        layoutFlow.minimumInteritemSpacing = Storyboard.minimumInteritemSpacingFlow
        layoutFlow.minimumLineSpacing = Storyboard.minimumLineSpacing
        layoutFlow.sectionInset = Storyboard.sectionInset
        
        // устанавливаем Waterfall layout нашему collection view
        collectionView?.collectionViewLayout = layoutFlow
    }

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
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Storyboard.reuseIdentifier, forIndexPath: indexPath) as! ImageCollectionViewCell

        //cell.cache = cache
        cell.tweetMedia = images[indexPath.row]

        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        if collectionView.collectionViewLayout is CHTCollectionViewWaterfallLayout{
            let newColumnNumber = Int(CGFloat(Storyboard.ColumnCountWaterfall) / scale)
            (collectionView.collectionViewLayout
                as! CHTCollectionViewWaterfallLayout).columnCount =
                newColumnNumber < 1 ? 1 :newColumnNumber
        }
       
        let ratio = CGFloat(images[indexPath.row].image.aspectRatio)
        let maxCellWidth = collectionView.bounds.size.width
        var size = CGSize(width: Storyboard.SizeSetting.width * scale,
                          height: Storyboard.SizeSetting.height * scale)
        if ratio > 1 {
            size.height /= ratio
        } else {
            size.width *= ratio
        }
        if size.width > maxCellWidth {
            size.width = maxCellWidth
            size.height = size.width / ratio
        }
        return size
    }
    /*
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        let leftRightInset = self.view.frame.size.width / 14.0
        return UIEdgeInsetsMake(0, leftRightInset, 0, leftRightInset)
    }*/

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
