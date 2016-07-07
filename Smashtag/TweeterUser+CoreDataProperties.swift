//
//  TweeterUser+CoreDataProperties.swift
//  Smashtag
//
//  Created by Ilya Dolgopolov on 07/07/16.
//  Copyright © 2016 Ilya Dolgopolov. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension TweeterUser {

    @NSManaged var name: String?
    @NSManaged var screenName: String?
    @NSManaged var tweets: NSSet?
}
