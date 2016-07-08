//
//  SearchedTweet.swift
//  Smashtag
//
//  Created by Ilya Dolgopolov on 08.07.16.
//  Copyright © 2016 Ilya Dolgopolov. All rights reserved.
//

import Foundation
import CoreData
import Twitter

class SearchedTweet: NSManagedObject {
    
    class func tweetWithMentionInfo(mentionInfo: Twitter.Tweet, inManagedObjectContext context: NSManagedObjectContext) -> SearchedTweet? {
        let request = NSFetchRequest(entityName: "SearchedTweet")
        request.predicate = NSPredicate(format: "uniqueId = %@", mentionInfo.id)
        
        if let tweet = (try? context.executeFetchRequest(request))?.first as? SearchedTweet {
            return tweet
        } else if let tweet = NSEntityDescription.insertNewObjectForEntityForName("SearchedTweet", inManagedObjectContext: context) as? SearchedTweet {
            tweet.uniqueId = mentionInfo.id
            tweet.text = mentionInfo.text
            for mn in mentionInfo.hashtags {
                tweet.mention = Mention.mentionWithMentionInfo(mn, withType: "hashtag", inManagedObjectContext: context)
            }
            
            for um in mentionInfo.userMentions {
                tweet.mention = Mention.mentionWithMentionInfo(um, withType: "userMentions", inManagedObjectContext: context)
            }
            return tweet
        }
        return nil
    }
}
