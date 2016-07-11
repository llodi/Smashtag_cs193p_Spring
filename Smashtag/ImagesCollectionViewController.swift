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
        static let SizeSetting = CGSize(width: 150.0, height: 200.0)
        
        static let ColumnCountWaterfall = 3
        static let minimumColumnSpacing:CGFloat = 1
        static let minimumInteritemSpacing:CGFloat = 1
        
        static let minimumLineSpacing:CGFloat = 1
        static let minimumInteritemSpacingFlow:CGFloat = 1
        static let sectionInset = UIEdgeInsets (top: 3, left: 3, bottom: 3, right: 3)
        static let columnCount:Int = 3
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let first = TweetsTracking.Tracking.values.first {
            searchText = first
        }
        
        collectionView?.delegate = self
        collectionView?.dataSource = self
        // Установка Layout
        setupLayout()

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
    
   
    private var layoutFlow = UICollectionViewFlowLayout()
    private var layoutWaterfall = CHTCollectionViewWaterfallLayout ()
   
    private var cache = NSCache()
    
    private var images: [ImageTweet] = []
    
    var tweets = [Array<Twitter.Tweet>]() {
        didSet {
            images = tweets.flatMap({$0}).map {
                tweet in tweet.media.map{ ImageTweet(tweet: tweet, image: $0)}}.flatMap({$0})
            images.sortInPlace { (let lowerRatio, let HigherRatio) -> Bool in
                lowerRatio.image.aspectRatio < HigherRatio.image.aspectRatio
            }
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
        
        let layout = CHTCollectionViewWaterfallLayout()
        
        layout.columnCount = Storyboard.ColumnCountWaterfall
        layout.minimumColumnSpacing = Storyboard.minimumColumnSpacing
        
        layout.sectionInset = Storyboard.sectionInset
        
        // Меняем атрибуты для FlowLayout
        // зазоры между ячейками и строками и
        // зазоры для секции
        layout.minimumInteritemSpacing = Storyboard.minimumInteritemSpacingFlow
        //layout.minimumLineSpacing = Storyboard.minimumLineSpacing
        layout.sectionInset = Storyboard.sectionInset
        
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

        cell.cache = cache
        cell.tweetMedia = images[indexPath.row]

        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        
        if collectionView.collectionViewLayout is CHTCollectionViewWaterfallLayout {
            let newColumnNumber = Int(CGFloat(Storyboard.ColumnCountWaterfall))
            (collectionView.collectionViewLayout
                as! CHTCollectionViewWaterfallLayout).columnCount =
                newColumnNumber < 1 ? 1 :newColumnNumber
        }
        
        let ratio = CGFloat(images[indexPath.row].image.aspectRatio)
        
        let maxCellWidth = collectionView.bounds.size.width
        
        var size = CGSize(width: Storyboard.SizeSetting.width ,
                          height: Storyboard.SizeSetting.height)
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
 }
