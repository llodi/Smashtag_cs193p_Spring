//
//  TweetTableViewCell.swift
//  Shashtag
//
//  Created by Ilya Dolgopolov on 26.06.16.
//  Copyright © 2016 Ilya Dolgopolov. All rights reserved.
//

import UIKit
import Twitter

class TweetTableViewCell: UITableViewCell {
    
    @IBOutlet weak var tweetScreenNameLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var tweetProfileImageView: UIImageView!
    @IBOutlet weak var tweetCreatedLabel: UILabel!
    
    var tweet: Twitter.Tweet? {
        didSet {
            updateUI()
        }
    }
    
    private func updateUI () {
        //reset any existing tweet info
        tweetTextLabel?.attributedText = nil
        tweetScreenNameLabel?.text = nil
        tweetProfileImageView?.image = nil
        tweetCreatedLabel?.text = nil
        
        //for _ in tweet.ment
        
        //load new info from tweet (if any)
        if let tweet = self.tweet {
            
            let myAttribute = [ NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleBody) ]
            let myString = NSMutableAttributedString(string: tweet.text, attributes: myAttribute )
         
            for hash in tweet.hashtags {
                myString.addAttribute(NSForegroundColorAttributeName, value: UIColor.redColor(), range: hash.nsrange)
            }
            
            for url in tweet.urls {
                myString.addAttribute(NSForegroundColorAttributeName, value: UIColor.blueColor(), range: url.nsrange)
            }
            
            for userMention in tweet.userMentions {
                myString.addAttribute(NSForegroundColorAttributeName, value: UIColor.orangeColor(), range: userMention.nsrange)
            }
            
            print("current text in label \(tweetTextLabel?.attributedText)")
            if tweetTextLabel?.attributedText != nil {
                for _ in tweet.media {
                    myString.appendAttributedString(NSAttributedString(string: " 📷"))
                    print ("weet.media")
                }
            }
            
            tweetTextLabel?.attributedText = myString
            
            tweetScreenNameLabel?.text = "\(tweet.user)" //tweet.user.description
            
            if let profileImageURL = tweet.user.profileImageURL {
                if let imageDate = NSData(contentsOfURL: profileImageURL) { //block main Thread
                    tweetProfileImageView?.image = UIImage(data: imageDate)
                }
            }
            
            let formatter = NSDateFormatter()
            if NSDate().timeIntervalSinceDate(tweet.created) > 24*60*60 {
                formatter.dateStyle = NSDateFormatterStyle.ShortStyle
            } else {
                formatter.timeStyle = NSDateFormatterStyle.ShortStyle
            }
            tweetCreatedLabel?.text = formatter.stringFromDate(tweet.created)
        }
    }
    
}
