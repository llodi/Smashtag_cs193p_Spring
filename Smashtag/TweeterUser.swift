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
 
}
