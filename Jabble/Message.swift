//
//  Message.swift
//  Jabble
//
//  Created by AJ Bronson on 6/8/16.
//  Copyright © 2016 PrecisionCodes. All rights reserved.
//

import Foundation

public let kGroupID = "group_id"

class Message: FirebaseType {
    
    private let kText = "text"
    private let kImportant = "important"
    private let kDateCreated = "created"
    private let kUserID = "user_id"
    
    var endpoint: String {
        return "messages"
    }

    var id: String?
    let text: String
    var important: Bool
    let dateCreated: NSTimeInterval
    let groupID: String
    let userID: String
    
    init(text: String, important: Bool, groupID: String, userID: String, dateCreated:NSTimeInterval = NSDate().timeIntervalSince1970) {
        self.text = text
        self.important = important
        self.groupID = groupID
        self.userID = userID
        self.dateCreated = dateCreated
    }
    
    required init?(dictionary: [String: AnyObject], id: String) {
        guard let text = dictionary[kText] as? String,
            let important = dictionary[kImportant] as? Bool,
            let dateCreated = dictionary[kDateCreated] as? Double,
            let groupID = dictionary[kGroupID] as? String,
            let userID = dictionary[kUserID] as? String else { return nil }
        self.text = text
        self.important = important
        self.dateCreated = NSTimeInterval(dateCreated)
        self.groupID = groupID
        self.userID = userID
        self.id = id
    }
    
    var dictionaryCopy: [String: AnyObject] {
        return [
                kText:text,
                kUserID:userID,
                kGroupID:groupID,
                kDateCreated:Double(dateCreated),
                kImportant:important,
                
        ]
    }
    
}