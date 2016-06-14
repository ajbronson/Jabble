//
//  UserController.swift
//  Jabble
//
//  Created by AJ Bronson on 6/8/16.
//  Copyright © 2016 PrecisionCodes. All rights reserved.
//

import Foundation
import Firebase

class UserController {
    
    static var currentUser: User?
    
    static func createUser(firstName: String, lastName: String, email: String, displayName: String, password: String, completion: (user: User?) -> Void) {
        FIRAuth.auth()?.createUserWithEmail(email, password: password, completion: { (user, error) in
            if let error = error  {
                print("There was an error while creating user: \(error.localizedDescription)")
                completion(user: nil)
            } else if let fbUser = user {
                var user = User(firstName: firstName, lastName: lastName, email: email, displayName: displayName, groups: [], id: fbUser.uid)
                user.save()
                self.currentUser = user
                completion(user: user)
            } else {
                completion(user: nil)
            }
        })
    }
    
    static func authUser(email: String, password: String, completion: (user: User?) -> Void) {
        FIRAuth.auth()?.signInWithEmail(email, password: password, completion: { (fbUser, error) in
            if let error = error {
                print("Was not able to log user in \(error.localizedDescription)")
                completion(user: nil)
            } else if let fbUser = fbUser {
                self.fetchUserWith(fbUser.uid, completion: { (user) in
                    guard let user = user else { completion(user: nil); return }
                    self.currentUser = user
                    completion(user: user)
                })
            } else {
                completion(user: nil)
            }
        })
    }
    
    static func fetchUserWith(identifier: String, completion: (user: User?) -> Void) {
        FirebaseController.ref.child("users").child(identifier).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            print(snapshot.value)
            guard let dataDict = snapshot.value as? [String: AnyObject],
                let user = User(dictionary: dataDict, id: snapshot.key) else { completion(user: nil); return }
            completion(user: user)
        })
    }
    
    static func fetchMultipleUsersWith(identifier: [String], completion: (users: [User]) -> Void) {
        var users = [User]()
        let group = dispatch_group_create()
        for id in identifier {
            dispatch_group_enter(group)
            FirebaseController.ref.child("users").child(id).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                if let dataDict = snapshot.value as? [String: AnyObject],
                    let user = User(dictionary: dataDict, id: snapshot.key) {
                    users.append(user)
                }
                dispatch_group_leave(group)
                
            })
        }
        dispatch_group_notify(group, dispatch_get_main_queue()) { 
            completion(users: users)
        }
    }
    
    static func addUserToGroup(group:Group) {
        if let id = group.id {
            self.currentUser?.groupIDs.append(id)
            self.currentUser?.save()
        }
    }
    
    static func fetchAllUsers(completion: (users: [User]) -> Void) {
        let ref = FirebaseController.ref.child("users")
        ref.observeEventType(.Value, withBlock:  { (data) in
            if let dataDict = data.value as? [String: [String: AnyObject]] {
                let users = dataDict.flatMap({User(dictionary: $0.1, id: $0.0)})
                completion(users: users)
            }
        })
    }

}