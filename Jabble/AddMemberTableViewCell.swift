//
//  AddMemberTableViewCell.swift
//  Jabble
//
//  Created by AJ Bronson on 6/10/16.
//  Copyright © 2016 PrecisionCodes. All rights reserved.
//

import UIKit

class AddMemberTableViewCell: UITableViewCell, addMemberProtocol, UITextFieldDelegate, addMemberTextChanged {

    @IBOutlet weak var addMemberTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addMemberTextField.delegate = self
        addMemberTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
    }
    
    func textFieldDidChange(textField: UITextField) {
        guard let text = addMemberTextField.text else { return }
        self.newText(text)
        becameFirstResponder()
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        becameFirstResponder()
    }
    
    func newText(text: String) {
        self.textChangeDelegate?.newText(text)
    }
    
    func becameFirstResponder() {
        self.textChangeDelegate?.becameFirstResponder()
    }
    
    func resignedFirstResponder() {
        self.textChangeDelegate?.resignedFirstResponder()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        addMemberTextField.resignFirstResponder()
        resignedFirstResponder()
        return true
    }
    
    var delegate: addMemberProtocol?
    var textChangeDelegate: addMemberTextChanged?
    
    func textFieldDidEndEditing(textField: UITextField) {
        if let member = addMemberTextField.text {
            addedMember(member)
        }
    }
    
    func addedMember(text: String) {
        self.delegate?.addedMember(text)
    }
    
}

protocol addMemberProtocol {
    func addedMember(text: String)
}

protocol addMemberTextChanged {
    func newText(text:String)
    func becameFirstResponder()
    func resignedFirstResponder()
}