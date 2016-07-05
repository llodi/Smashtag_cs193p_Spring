//
//  Tweet+CoreDataProperties.swift
//  Smashtag
//
//  Created by Ilya Dolgopolov on 05/07/16.
//  Copyright © 2016 Ilya Dolgopolov. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Tweet {

    @NSManaged var posted: NSDate?
    @NSManaged var text: String?
    @NSManaged var unique: String?
    @NSManaged var tweeter: TweeterUser?

}
