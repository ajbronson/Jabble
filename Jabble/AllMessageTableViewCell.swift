//
//  AllMessageTableViewCell.swift
//  Jabble
//
//  Created by AJ Bronson on 6/10/16.
//  Copyright © 2016 PrecisionCodes. All rights reserved.
//

import UIKit

class AllMessageTableViewCell: UITableViewCell {

    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var groupMembersCell: UILabel!
    @IBOutlet weak var groupMessageLabel: UILabel!
    
    func updateWith(group:Group, messages: [Message], users: [User]) {
        guard let id = LoginPersistenceController.loggedInUserID else { return }
        groupNameLabel.text = group.name
        
        var userText = ""
        for user in users {
            if user.id != id {
               userText += "\(user.firstName) \(user.lastName), "
            }
        }
        
        if userText.characters.count > 0 {
            userText = userText.substringToIndex(userText.endIndex.predecessor())
            userText = userText.substringToIndex(userText.endIndex.predecessor())
            groupMembersCell.text = userText
        } else {
            groupMembersCell.text = ""
        }

        if let lastMessage = messages.last {
            groupMessageLabel.text = lastMessage.text
        } else {
            groupMessageLabel.text = "(No Messages Yet)"
        }
    }

}
