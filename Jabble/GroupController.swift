//
//  GroupController.swift
//  Jabble
//
//  Created by AJ Bronson on 6/8/16.
//  Copyright © 2016 PrecisionCodes. All rights reserved.
//

import Foundation

class GroupController {
    
    static func addMessageToGroup(text: String, important: Bool, groupID: String) {
        if let userID = UserController.currentUser?.id {
            var newMessage = Message(text: text, important: important, groupID: groupID, userID: userID)
            newMessage.save()
        }
    }
    
    static func toggleMessageImportance(message: Message) {
        message.important = !message.important
    }
    
    static func createGroup(type: String, name: String, userIDs: [String]) {
        if let userID = UserController.currentUser?.id {
            Group(type: type, kingID: userID, name: name, users: userIDs).save()
        }
    }
    
    static func deleteGroup(group: Group) {
       group.delete()
    }
    
    static func observeGroups(completion: (groups: [Group]) -> Void) {
        
        if let currentUser = UserController.currentUser {
            var groups: [Group] = [Group]()
            let dispatchGroup = dispatch_group_create()
            for groupID in currentUser.groupIDs {
                dispatch_group_enter(dispatchGroup)
                let groupRef = FirebaseController.ref.child("groups").child(groupID)
                groupRef.observeEventType(.Value, withBlock: { (data) in
                    guard let dataDict = data.value as? [String: AnyObject] else { completion(groups: []); return }
                    if let group = Group(dictionary: dataDict, id: groupID) {
                        groups.append(group)
                    }
                    dispatch_group_leave(dispatchGroup)
                })
            }
            dispatch_group_notify(dispatchGroup, dispatch_get_main_queue(), { 
                completion(groups: groups)
            })
        }
    }
    
    static func observeMessagesInSingleGroup(groupID: String, completion: (messages: [Message]) -> Void) {
        let messageRef = FirebaseController.ref.child("messages").queryOrderedByChild(kGroupID).queryEqualToValue(groupID)
        messageRef.observeEventType(.Value, withBlock:  { (data) in
            guard let dataDict = data.value as? [String : [String: AnyObject]] else { completion(messages: []); return }
            let newMessages = dataDict.flatMap({Message(dictionary: $0.1, id: $0.0)})
            completion(messages: newMessages)
        })
    }
    
    static func observeMessagesInGroups(groups: [Group], completion: (messages: [Message]) -> Void) {
        let groupIDs = groups.map({$0.id})
        var messages: [Message] = [Message]()
        let dispatchGroup = dispatch_group_create()
        for groupID in groupIDs {
            if let groupID = groupID {
                dispatch_group_enter(dispatchGroup)
                let messageRef = FirebaseController.ref.child("messages").queryOrderedByChild(kGroupID).queryEqualToValue(groupID)
                messageRef.observeEventType(.Value, withBlock:  { (data) in
                    guard let dataDict = data.value as? [String : [String: AnyObject]] else { dispatch_group_leave(dispatchGroup); return }
                    let newMessages = dataDict.flatMap({Message(dictionary: $0.1, id: $0.0)})
                    messages += newMessages
                    dispatch_group_leave(dispatchGroup)
                })
            }
        }
        dispatch_group_notify(dispatchGroup, dispatch_get_main_queue(), {
            completion(messages: messages)
        })
    }
}