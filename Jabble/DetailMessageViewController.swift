//
//  DetailMessageViewController.swift
//  Jabble
//
//  Created by AJ Bronson on 6/13/16.
//  Copyright © 2016 PrecisionCodes. All rights reserved.
//

import UIKit

class DetailMessageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, importantButtonProtocol{
    
    @IBOutlet weak var tableView: UITableView!
    
    var groupID: String?
    var messages: [Message]?
    var users: [User]?
    var group: Group? {
        didSet {
            self.title = group?.name
        }
    }
    var movedScreenUpByPoints = CGPoint(x: 0.0, y: 0.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableViewAutomaticDimension
        observeMessages()
        observeGroup()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: self.view.window)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: self.view.window)
        if let group = group, id = LoginPersistenceController.loggedInUserID {
            self.title = group.name
            if group.kingID != id {
                self.navigationItem.rightBarButtonItem = nil
            }
        }
        
    }
    
    func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if let messages = messages {
            if indexPath.row == messages.count - 1 {
                let indexPath = NSIndexPath(forRow: messages.count - 1, inSection: 0)
                let rectOfCellInTableView: CGRect = tableView.rectForRowAtIndexPath(indexPath)
                print("THIS IS THE HEIGHT >>>>>>>>>>>>>>>>>>>> \(rectOfCellInTableView.height), width is \(rectOfCellInTableView.width) and origin \(rectOfCellInTableView.origin)")
            }
            
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
            cell?.delegate = self
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
    
    func observeGroup() {
        if let groupID = groupID {
            GroupController.observeSingleGroup(groupID, completion: { (group) in
                self.group = group
                self.tableView.reloadData()
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
//            tableView.frame = CGRectMake(tableView.frame.origin.x, tableView.frame.origin.y, tableView.frame.size.width, /*tableView.contentSize.height*/50);
//            tableView.frame.size.height = 50
            scrollToBottom()
        }
    

    
//    func keyboardWillShow(sender: NSNotification) {
//        guard let userInfo: [NSObject: AnyObject] = sender.userInfo,
//            keyboardSize: CGSize = userInfo[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue.size,
//            offset: CGSize = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue.size else { return }
//        
//        var origin = CGPoint()
//        if let messages = messages where messages.count > 0 {
//            let indexPath = NSIndexPath(forRow: messages.count - 1, inSection: 0)
//            let rectOfCellInTableView: CGRect = tableView.rectForRowAtIndexPath(indexPath)
//            origin = rectOfCellInTableView.origin
//        }
//        
//        if tableView.frame.height - keyboardSize.height - origin.y - 35 <= 0 {
//            if keyboardSize.height == offset.height && self.view.frame.origin.y == 0 {
//                UIView.animateWithDuration(0.1, animations: {
//                    self.view.frame.origin.y -= keyboardSize.height
//                    self.movedScreenUpByPoints = CGPoint(x: 0.0, y: (keyboardSize.height))
//                })
//            } else {
//                UIView.animateWithDuration(0.1, animations: {
//                    self.view.frame.origin.y += (keyboardSize.height - offset.height)
//                    self.movedScreenUpByPoints = CGPoint(x: 0.0, y: (keyboardSize.height - offset.height))
//                })
//            }
//        } else {
//            movedScreenUpByPoints = CGPoint(x: 0.0, y: 0.0)
//            tableView.frame = CGRect(x: 0.0, y: 0.0, width: Double(self.view.frame.width), height: 10.0)
//        }
//
//        scrollToBottom()
//    }
    
    func keyboardWillHide(sender: NSNotification) {
        guard let userInfo: [NSObject: AnyObject] = sender.userInfo,
            keyboardSize: CGSize = userInfo[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue.size else { return }
        self.view.frame.origin.y  += keyboardSize.height
        scrollToBottom()
    }
    
//    func keyboardWillHide(sender: NSNotification) {
//        self.view.frame.origin.y  += movedScreenUpByPoints.y
//        scrollToBottom()
//    }
    
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toGroupDetail" {
            guard let detailVC = segue.destinationViewController.childViewControllers[0] as? CreateGroupTableViewController,
                let group = group else { return }
            let _ = detailVC.view
            detailVC.updateWith(group)
        } else if segue.identifier == "toImportant" {
            guard let detailVC = segue.destinationViewController as? ImportantTableViewController,
                let users = users, let messages = messages else { return }
            detailVC.messages = messages
            detailVC.users = users
        }
    }
    
    func importantButtonToggle(sender: DetailMessageTableViewCell) {
        guard let index = tableView.indexPathForCell(sender),
            let messages = messages else { return }
        var messageToChange = messages[index.row]
        if messageToChange.userID == LoginPersistenceController.loggedInUserID {
            messageToChange.important = !messageToChange.important
            messageToChange.save()
            let cell = tableView.cellForRowAtIndexPath(index) as? DetailMessageTableViewCell
            cell?.setImageImportant(messageToChange.important)
        }
    }
}

