//
//  DetailMessageTableViewCell.swift
//  Jabble
//
//  Created by AJ Bronson on 6/10/16.
//  Copyright © 2016 PrecisionCodes. All rights reserved.
//

import UIKit

class DetailMessageTableViewCell: UITableViewCell {

    @IBOutlet weak var importantMessage: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var textMessageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textMessageLabel.lineBreakMode = .ByWordWrapping
        textMessageLabel.numberOfLines = 0
    }
    
    func updateWith(users: [User], message: Message) {
        let user = users.filter({$0.id == message.userID})
        if let user = user.first {
            nameLabel.text = user.firstName
            textMessageLabel.text = message.text
        }
        
        if message.userID != LoginPersistenceController.loggedInUserID {
            importantMessage.hidden = true
        }
    }

    @IBAction func importantButtonTapped(sender: AnyObject) {
        
    }
}
