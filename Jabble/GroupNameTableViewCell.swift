//
//  GroupNameTableViewCell.swift
//  Jabble
//
//  Created by AJ Bronson on 6/10/16.
//  Copyright © 2016 PrecisionCodes. All rights reserved.
//

import UIKit

class GroupNameTableViewCell: UITableViewCell, groupNameProtocol, UITextFieldDelegate {

    @IBOutlet weak var nameTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        nameTextField.delegate = self
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        nameTextField.resignFirstResponder()
        return true
    }
    
    var delegate: groupNameProtocol?
    
    func textFieldDidEndEditing(textField: UITextField) {
        if let name = nameTextField.text {
            getName(name)
        }
    }
    
    func getName(name: String) {
        self.delegate?.getName(name)
    }
}

protocol groupNameProtocol {
    func getName(name: String)
}
