//
//  DetailMessageViewController.swift
//  Jabble
//
//  Created by AJ Bronson on 6/13/16.
//  Copyright © 2016 PrecisionCodes. All rights reserved.
//

import UIKit

class DetailMessageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var tableView: UITableView!

    var groupID: String?
    var messages: [Message]?
    var users: [User]?
    var group: Group?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableViewAutomaticDimension
        observeMessages()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: self.view.window)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: self.view.window)
        if let group = group {
            self.title = group.name
        }
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages?.count ?? 0
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        messageTextField.resignFirstResponder()
        return true
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("detailCell", forIndexPath: indexPath) as? DetailMessageTableViewCell
        if let messages = messages, users = users {
            cell?.updateWith(users, message: messages[indexPath.row])
        }
        return cell ?? UITableViewCell()
    }
    
    func updateWith(groupID: String, messages: [Message], users: [User], group: Group) {
        self.groupID = groupID
        self.users = users
        self.messages = messages
        self.group = group
    }
    
    @IBOutlet weak var messageTextField: UITextField!
    
    @IBAction func sendMessageButtonTapped(sender: UIButton) {
        guard let messageText = messageTextField.text,
            let user = UserController.currentUser,
            let userID = user.id,
            let groupID = groupID where messageText.characters.count > 0 else { return }
        
        var message = Message(text: messageText, important: false, groupID: groupID, userID: userID)
        message.save()
        messageTextField.text = ""
    }
    
    func observeMessages() {
        
        if let groupID = groupID {
            GroupController.observeMessagesInSingleGroup(groupID, completion: { (messages) in
                let sortedMessages = messages.sort({$0.dateCreated < $1.dateCreated})
                self.messages = sortedMessages
                self.tableView.reloadData()
                if messages.count > 0 {
                    let index: NSIndexPath = NSIndexPath(forRow: messages.count - 1, inSection: 0)
                    self.tableView.scrollToRowAtIndexPath(index, atScrollPosition: .Top, animated: false)
                }
            })
        }
    }
    
    func keyboardWillShow(sender: NSNotification) {
        guard let userInfo: [NSObject: AnyObject] = sender.userInfo,
            keyboardSize: CGSize = userInfo[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue.size,
            offset: CGSize = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue.size else { return }
        if keyboardSize.height == offset.height && self.view.frame.origin.y == 0 {
            UIView.animateWithDuration(0.1, animations: {
                self.view.frame.origin.y -= keyboardSize.height
            })
        } else {
            UIView.animateWithDuration(0.1, animations: {
                self.view.frame.origin.y += (keyboardSize.height - offset.height)
            })
        }
        scrollToBottom()
    }
    
    func keyboardWillHide(sender: NSNotification) {
        guard let userInfo: [NSObject: AnyObject] = sender.userInfo,
            keyboardSize: CGSize = userInfo[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue.size else { return }
        self.view.frame.origin.y  += keyboardSize.height
        scrollToBottom()
    }
    
    func scrollToBottom() {
        if let messages = messages {
            if messages.count > 0 {
                let indexPath = NSIndexPath(forRow: (messages.count - 1), inSection: 0)
                self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: false)
            }
        }
    }
    
    func addImportantView() {
        let importantTableView = UITableView(frame: UIScreen.mainScreen().bounds, style: UITableViewStyle.Plain)
        importantTableView.delegate      =   self
        importantTableView.dataSource    =   self
        importantTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(importantTableView)
    }
}

