//
//  TweeterUser.swift
//  Smashtag
//
//  Created by Ilya Dolgopolov on 05/07/16.
//  Copyright © 2016 Ilya Dolgopolov. All rights reserved.
//

import Foundation
import CoreData
import Twitter


class TweeterUser: NSManagedObject {
    
    class func twitterUserWithTwitterInfo(twitterInfo: Twitter.User, inManagedObjectContext context: NSManagedObjectContext) -> TweeterUser? {
        
        let request = NSFetchRequest(entityName: "TweeterUser")
        request.predicate = NSPredicate(format: "screenName = %@", twitterInfo.screenName)
        if let user = (try? context.executeFetchRequest(request))?.first as? TweeterUser {
            return user
        } else if let user = NSEntityDescription.insertNewObjectForEntityForName("TweeterUser", inManagedObjectContext: context) as? TweeterUser {
            user.screenName = twitterInfo.screenName
            user.name = twitterInfo.name
            return user
        }
        return nil	
    }
    
    class func tweetCountWithMentionByTweeterUser(inManagedObjectContext context: NSManagedObjectContext, withPredicate predicate: String) {
        let requestUsers = NSFetchRequest(entityName: "TweeterUser")
        requestUsers.predicate = NSPredicate(format: "any tweets.text contains[c] %@", predicate)
        if let users = (try? context.executeFetchRequest(requestUsers)) as? [TweeterUser] {
            for u in users {
                var count = 0
                let request = NSFetchRequest(entityName: "Tweet")
                request.predicate = NSPredicate(format: "text contains[c] %@ and tweeter = %@", predicate, u)
                context.performBlockAndWait {
                    count = context.countForFetchRequest(request, error: nil)
                }
                u.count = count
            }
        }
        do {
            try context.save()
        } catch let error {
            print("Core Data Error: \(error)")
        }
    }
}
