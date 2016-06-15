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
    
    var delegate: importantButtonProtocol?
    var showImportant: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textMessageLabel.lineBreakMode = .ByWordWrapping
        textMessageLabel.numberOfLines = 0
        showImportant = false
    }
    
    func updateWith(users: [User], message: Message) {
        let user = users.filter({$0.id == message.userID})
        if let user = user.first {
            nameLabel.text = user.firstName
            textMessageLabel.text = message.text
        }
        
        if message.userID != LoginPersistenceController.loggedInUserID {
            importantMessage.setImage(UIImage(named: "noImage"), forState: .Normal)
        } else {
            if message.important {
                importantMessage.setImage(UIImage(named: "important"), forState: .Normal)
            } else {
                importantMessage.setImage(UIImage(named: "notImportant"), forState: .Normal)
            }
        }
        
        if showImportant {
            importantMessage.setImage(UIImage(named: "important"), forState: .Normal)
        }
    }
    

    @IBAction func importantButtonTapped(sender: AnyObject) {
        self.delegate?.importantButtonToggle(self)
    }
    
    func setImageImportant(important: Bool) {
        if important {
             importantMessage.setImage(UIImage(named: "important"), forState: .Normal)
        } else {
            importantMessage.setImage(UIImage(named: "notImportant"), forState: .Normal)
        }
    }
}

protocol importantButtonProtocol {
    func importantButtonToggle(sender: DetailMessageTableViewCell)
}
