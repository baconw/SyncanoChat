//
//  Message+CoreDataProperties.swift
//  SyncanoChat
//
//  Created by dongyi228 on 16/7/29.
//  Copyright © 2016年 dongyi228. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Message {

    @NSManaged var senderid: String?
    @NSManaged var text: String?
    @NSManaged var create_at: NSDate?

}
