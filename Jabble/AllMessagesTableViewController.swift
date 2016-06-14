//
//  AllMessagesTableViewController.swift
//  Jabble
//
//  Created by AJ Bronson on 6/9/16.
//  Copyright © 2016 PrecisionCodes. All rights reserved.
//

import UIKit

class AllMessagesTableViewController: UITableViewController {
    
    var groups = [Group]()
    var messages = [Message]()
    var id: String?
    var users:[String: [User]] = [:] {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    static let sharedController = AllMessagesTableViewController()

    override func viewDidLoad() {
        
        super.viewDidLoad()
        guard let user = LoginPersistenceController.loadUser(), id = user.id else { performSegueWithIdentifier("toLogin", sender: self); return }
        self.id = id
        
    }
    
    override func viewWillAppear(animated: Bool) {
        guard let id = id else { return }
        UserController.fetchUserWith(id) { (user) in
            if let user = user {
                UserController.currentUser = user
                GroupController.observeGroups { (groups) in
                    let groups = groups.sort({$0.dateCreated < $1.dateCreated})
                    GroupController.observeMessagesInGroups(groups, completion: { (messages) in
                        let sortedMessages = messages.sort({$0.dateCreated < $1.dateCreated})
                        self.messages = sortedMessages
                        self.tableView.reloadData()
                    })
                    for i in 0..<groups.count {
                        UserController.fetchMultipleUsersWith(groups[i].userIDs, completion: { (users) in
                            self.users.updateValue(users, forKey: "\(i)")
                        })
                    }
                    self.groups = groups
                    self.tableView.reloadData()
                }
            }
        }
    }


    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("allMessageCell", forIndexPath: indexPath) as? AllMessageTableViewCell
        var thisGroupMessages = [Message]()
        var thisGroupUsers = [User]()

        if let id = groups[indexPath.row].id {
            thisGroupMessages = messages.filter({$0.groupID == id})
        }
        if let groupUsers = self.users["\(indexPath.row)"] {
            thisGroupUsers = groupUsers
        }
        
        cell?.updateWith(groups[indexPath.row], messages: thisGroupMessages, users: thisGroupUsers)
        return cell ?? UITableViewCell()
    }

    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let group = groups[indexPath.row]
            guard let id = group.id else { return }
            if group.kingID == LoginPersistenceController.loggedInUserID {
                UserController.fetchMultipleUsersWith(group.userIDs, completion: { (users) in
                    for user in users {
                        var user = user
                        user.groupIDs = user.groupIDs.filter({$0 != id})
                        user.save()
                        //self.tableView.reloadData()
                        //self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                    }
                    group.delete()
                })
            } else {
                if let userID = LoginPersistenceController.loggedInUserID {
                    UserController.fetchUserWith(userID, completion: { (user) in
                        if let user = user {
                            var user = user
                            user.groupIDs = user.groupIDs.filter({$0 != id})
                            user.save()
                            //self.tableView.reloadData()
                            //self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                        }
                    })
                }
            }
        }
    }
 
 
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toMessageDetail" {
            if let detailVC = segue.destinationViewController as? DetailMessageViewController,
                let index = tableView.indexPathForSelectedRow, id = groups[index.row].id,
                let userArray = users["\(index.row)"] {
                FirebaseController.ref.child("messages").removeAllObservers()
                detailVC.updateWith(id, messages: messages.filter({$0.groupID == id}), users: userArray, group: groups[index.row])
                
            }
        }
    }
}

