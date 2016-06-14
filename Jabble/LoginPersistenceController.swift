//
//  LoginPersistenceController.swift
//  Jabble
//
//  Created by AJ Bronson on 6/9/16.
//  Copyright © 2016 PrecisionCodes. All rights reserved.
//

import Foundation

class LoginPersistenceController {
    
    static let keyLoggedInUser = "login"
    
    static var loggedInUserID: String? {
        let user = LoginPersistenceController.loadUser()
        return user?.id
    }
    
    //I'm not setting the user yet
    static func saveUser(user: User) {
        if let id = user.id {
            let userDict = user.dictionaryCopy
            let dictionary2 = [id: userDict]
            NSUserDefaults.standardUserDefaults().setObject(dictionary2, forKey: keyLoggedInUser)
        }
    }
    
    static func loadUser() -> User? {
        guard let loggedInUser = NSUserDefaults.standardUserDefaults().objectForKey(keyLoggedInUser) as? [String: [String : AnyObject]],
            let id = loggedInUser.keys.first,
            let dictionary = loggedInUser[id] else { return nil }
        return User(dictionary: dictionary, id: id)
    }
    
    static func removeUser() {
        NSUserDefaults.standardUserDefaults().setObject("", forKey: keyLoggedInUser)
    }
    
}