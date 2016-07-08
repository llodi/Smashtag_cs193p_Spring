//
//  Mention.swift
//  Smashtag
//
//  Created by Ilya Dolgopolov on 08.07.16.
//  Copyright © 2016 Ilya Dolgopolov. All rights reserved.
//

import Foundation
import CoreData
import Twitter

class Mention: NSManagedObject {

    class func mentionWithMentionInfo(mentionInfo: Twitter.Mention, withType type: String, inManagedObjectContext context: NSManagedObjectContext) -> Mention? {
        let request = NSFetchRequest(entityName: "Mention")
        request.predicate = NSPredicate(format: "text = %@", mentionInfo.keyword)
        if let mention = (try? context.executeFetchRequest(request))?.first as? Mention {
            return mention
        } else if let mention = NSEntityDescription.insertNewObjectForEntityForName("Mention", inManagedObjectContext: context) as? Mention {
            mention.type = type
            mention.text = mentionInfo.keyword
            return mention
        }
        return nil
    }
    
    class func mentionCountWithMention(inManagedObjectContext context: NSManagedObjectContext, withPredicate predicate: String) {
        let requestMentions = NSFetchRequest(entityName: "Mention")
        requestMentions.predicate = NSPredicate(format: "any tweets.text contains[c] %@", predicate)
        if let mentions = (try? context.executeFetchRequest(requestMentions)) as? [Mention] {
            for m in mentions {
                var count = 0
                let request = NSFetchRequest(entityName: "SearchedTweet")
                request.predicate = NSPredicate(format: "text contains[c] %@ and mention = %@", predicate, m)
                context.performBlockAndWait {
                    count = context.countForFetchRequest(request, error: nil)
                }
                m.count = count
            }
        }
        do {
            try context.save()
        } catch let error {
            print("Core Data Error: \(error)")
        }
    }

}
