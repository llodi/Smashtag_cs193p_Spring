//
//  Mention+CoreDataProperties.swift
//  Smashtag
//
//  Created by Ilya Dolgopolov on 08.07.16.
//  Copyright © 2016 Ilya Dolgopolov. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Mention {

    @NSManaged var count: NSNumber?
    @NSManaged var text: String?
    @NSManaged var type: String?
    @NSManaged var tweets: NSSet?
}
