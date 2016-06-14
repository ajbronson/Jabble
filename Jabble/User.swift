//
//  User.swift
//  Jabble
//
//  Created by AJ Bronson on 6/8/16.
//  Copyright © 2016 PrecisionCodes. All rights reserved.
//

import Foundation

class User: FirebaseType, Equatable {
    
    private let kFirst = "first"
    private let kLast = "last"
    private let kEmail = "email"
    private let kDisplayName = "displayName"
    private let kCreated = "dateCreated"
    private let kGroup = "group"
    
    var endpoint: String {
        return "users"
    }
    
    let firstName: String
    let lastName: String
    let email: String
    let displayName: String
    let dateCreated: NSTimeInterval
    var groupIDs: [String]
    var id: String?
    
    init(firstName: String, lastName: String, email: String, displayName: String, groups: [String]?, dateCreated:NSTimeInterval = NSDate().timeIntervalSince1970, id: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.displayName = displayName
        self.dateCreated = dateCreated
        self.id = id
        if let groups = groups {
            self.groupIDs = groups
        } else {
            self.groupIDs = []
        }
    }
    
    required init?(dictionary: [String: AnyObject], id: String) {
        guard let first = dictionary[kFirst] as? String,
            let last = dictionary[kLast] as? String,
            let email = dictionary[kEmail] as? String,
            let displayName = dictionary[kDisplayName] as? String,
            let dateCreated = dictionary[kCreated] as? Double  else { return nil }
        self.id = id
        self.firstName = first
        self.lastName = last
        self.displayName = displayName
        self.email = email
        self.dateCreated = NSTimeInterval(dateCreated)
        if let groups = dictionary[kGroup] as? [String: AnyObject] {
            self.groupIDs = groups.flatMap({$0.0})
        } else {
            self.groupIDs = []
        }
    }
    
    var groupIDDictionary: [String: AnyObject] {
        var dictionary: [String:AnyObject] = [:]
        
        for groupID in groupIDs {
            dictionary.updateValue(true, forKey: groupID)
        }
        return dictionary
    }
    
    var dictionaryCopy: [String: AnyObject] {
        return [
            kFirst:firstName,
            kLast:lastName,
            kEmail:email,
            kDisplayName:displayName,
            kCreated:Double(dateCreated),
            kGroup:groupIDDictionary
        ]
    }
}

func ==(lhs: User, rhs: User) -> Bool {
    return lhs.id == rhs.id
}


