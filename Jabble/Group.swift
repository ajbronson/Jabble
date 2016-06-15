//
//  Group.swift
//  Jabble
//
//  Created by AJ Bronson on 6/8/16.
//  Copyright © 2016 PrecisionCodes. All rights reserved.
//

import Foundation


class Group: FirebaseType {
    
    private let kType = "type"
    private let kName = "name"
    private let kKingID = "king"
    private let kDateCreated = "created"
    private let kUsers = "users"
    
    var endpoint: String {
        return "groups"
    }
    
    var id: String?
    let type: String
    let kingID: String
    var name: String
    let dateCreated: NSTimeInterval
    
    var userIDs: [String]
    
    
    init(type: String, kingID: String, name: String, users: [String], dateCreated:NSTimeInterval = NSDate().timeIntervalSince1970) {
        self.type = type
        self.name = name
        self.kingID = kingID
        self.dateCreated = dateCreated
        self.userIDs = users
    }
    
    required init?(dictionary: [String: AnyObject], id: String) {
        guard let type = dictionary[kType] as? String,
            let dateCreated = dictionary[kDateCreated] as? Double,
            let kingID = dictionary[kKingID] as? String,
            let userIDs = dictionary[kUsers] as? [String: AnyObject],
            let name = dictionary[kName] as? String else { return nil }
        self.id = id
        self.type = type
        self.dateCreated = NSTimeInterval(dateCreated)
        self.name = name
        self.kingID = kingID
        self.userIDs = userIDs.flatMap({$0.0})
    }
    
    var userDictionary: [String: AnyObject] {
        var dictionary: [String:AnyObject] = [:]
        for userID in userIDs {
            dictionary.updateValue(true, forKey: userID)
        }
        return dictionary
    }
    
    var dictionaryCopy: [String: AnyObject] {
        return [
            kName: name,
            kDateCreated: Double(dateCreated),
            kType: type,
            kKingID: kingID,
            kUsers: userDictionary
        ]
    }
    
    func save() {
        var newEndpoint = FirebaseController.ref.child(endpoint)
        
        if let id = id {
            newEndpoint = newEndpoint.child(id)
        } else {
            newEndpoint = newEndpoint.childByAutoId()
            self.id = newEndpoint.key
        }
        newEndpoint.updateChildValues(dictionaryCopy)
        
        for userID in userIDs {
            UserController.fetchUserWith(userID, completion: { (user) in
                if let user = user, id = self.id {
                    var user = user
                    user.groupIDs.append(id)
                    user.save()
                }
            })
        }
    }
    
    func delete() {
        guard let id = id else { return }
        FirebaseController.ref.child(endpoint).child(id).removeValue()
        let messageRef = FirebaseController.ref.child("messages").queryOrderedByChild(kGroupID).queryEqualToValue(id)
        messageRef.observeEventType(.Value, withBlock:  { (data) in
            guard let dataDict = data.value as? [String : [String: AnyObject]] else { return }
            let newMessages = dataDict.flatMap({Message(dictionary: $0.1, id: $0.0)})
            for message in newMessages {
                message.delete()
            }
        })
    }
    
}
