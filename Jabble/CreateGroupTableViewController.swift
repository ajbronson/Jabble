//
//  CreateGroupTableViewController.swift
//  Jabble
//
//  Created by AJ Bronson on 6/9/16.
//  Copyright © 2016 PrecisionCodes. All rights reserved.
//

import UIKit

class CreateGroupTableViewController: UITableViewController, createGroupProtocol, groupNameProtocol, addMemberProtocol, UITextFieldDelegate, addMemberTextChanged {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    var group: Group?
    
    var member: String?
    var name: String?
    
    var nameTextField: UITextField?
    var memberTextField: UITextField?
    
    var numberOfAddedUsers = 0
    var allUsers = [User]()
    var filteredUsers = [User]()
    var addedMembers = [User]()
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return 3 + numberOfAddedUsers
        } else {
            return filteredUsers.count
        }
        
    }
    
    func addedMember(text: String) {
        self.member = text
    }
    
    func getName(name: String) {
        self.name = name
    }
    
    
    func createGroupTapped() {
        FirebaseController.ref.child("users").removeAllObservers()
        if let group = group {
            guard let name = nameTextField?.text,
                let loggedInUserID = LoginPersistenceController.loggedInUserID where name.characters.count > 0 && addedMembers.count > 0 else { showAlert(); return }
            group.name = name
            var userIDs = addedMembers.flatMap({$0.id})
            saveDeleteUsers(group.userIDs, newIds: userIDs, groupID: group.id)
            userIDs.append(loggedInUserID)
            group.userIDs = userIDs
            group.save()
        } else {
            guard let user = UserController.currentUser, id = user.id, name = name where name.characters.count > 0 && addedMembers.count > 0  else { showAlert(); return }
            var memberIDs = addedMembers.flatMap({$0.id})
            memberIDs.append(id)
            let group = Group(type: "Closed", kingID: id, name: name, users: memberIDs)
            group.save()
        }
        sleep(1)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            if numberOfAddedUsers == 0 {
                
                switch indexPath.row {
                    
                case 0:
                    let cell = tableView.dequeueReusableCellWithIdentifier("nameCell", forIndexPath: indexPath) as? GroupNameTableViewCell
                    cell?.delegate = self
                    self.nameTextField = cell?.nameTextField
                    if let group = group {
                        nameTextField?.text = group.name
                    }
                    return cell ?? UITableViewCell()
                    
                case 1 :
                    let cell = tableView.dequeueReusableCellWithIdentifier("addMemberCell", forIndexPath: indexPath) as? AddMemberTableViewCell
                    cell?.delegate = self
                    cell?.textChangeDelegate = self
                    self.memberTextField = cell?.addMemberTextField
                    return cell ?? UITableViewCell()
                    
                case 2:
                    let cell = tableView.dequeueReusableCellWithIdentifier("createGroupCell", forIndexPath: indexPath) as? CreateButtonTableViewCell
                    cell?.delegate = self
                    if let _ = group {
                        cell?.createButtonText.setTitle("Save", forState: .Normal)
                    }
                    return cell ?? UITableViewCell()
                    
                default:
                    let cell = tableView.dequeueReusableCellWithIdentifier("memberCell", forIndexPath: indexPath)
                    cell.textLabel?.text = allUsers[0].firstName
                    return cell
                    
                }
            } else {
                
                switch indexPath.row {
                    
                case 0:
                    let cell = tableView.dequeueReusableCellWithIdentifier("nameCell", forIndexPath: indexPath) as? GroupNameTableViewCell
                    cell?.delegate = self
                    self.nameTextField = cell?.nameTextField
                    if let group = group {
                        nameTextField?.text = group.name
                    }
                    return cell ?? UITableViewCell()
                    
                case 1...numberOfAddedUsers:
                    let cell = tableView.dequeueReusableCellWithIdentifier("memberCell", forIndexPath: indexPath)
                    cell.textLabel?.text = addedMembers[indexPath.row - 1].displayName
                    //these are the added users
                    return cell
                    
                case numberOfAddedUsers + 1 :
                    let cell = tableView.dequeueReusableCellWithIdentifier("addMemberCell", forIndexPath: indexPath) as? AddMemberTableViewCell
                    cell?.delegate = self
                    cell?.textChangeDelegate = self
                    self.memberTextField = cell?.addMemberTextField
                    return cell ?? UITableViewCell()
                    
                case numberOfAddedUsers + 2:
                    let cell = tableView.dequeueReusableCellWithIdentifier("createGroupCell", forIndexPath: indexPath) as? CreateButtonTableViewCell
                    cell?.delegate = self
                    return cell ?? UITableViewCell()
                    
                default:
                    let cell = tableView.dequeueReusableCellWithIdentifier("memberCell", forIndexPath: indexPath)
                    cell.textLabel?.text = allUsers[0].firstName
                    return cell
                    
                }
            }
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("memberCell", forIndexPath: indexPath)
            cell.textLabel?.text = filteredUsers[indexPath.row].displayName
            return cell
        }
        
        
        
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 && filteredUsers.count > 0 {
            return "Users"
        } else {
            return ""
        }
    }
    
    
    
     // Override to support conditional editing of the table view.
     override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.section == 1 {
            return false
        } else if indexPath.row == 0 || indexPath.row == numberOfAddedUsers + 1 || indexPath.row == numberOfAddedUsers + 2 {
            return false
        } else {
           return true
        }
     }
    
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 && indexPath.row != 0 && indexPath.row != numberOfAddedUsers + 1 && indexPath.row != numberOfAddedUsers + 2 && editingStyle == .Delete {
            numberOfAddedUsers -= 1
            tableView.beginUpdates()
            
            allUsers.append(addedMembers[indexPath.row - 1])
            filteredUsers.append(addedMembers[indexPath.row - 1])
            
            let index = NSIndexPath(forRow: filteredUsers.count - 1, inSection: 1)
            self.tableView.insertRowsAtIndexPaths([index], withRowAnimation: .Left)
            
            tableView.reloadSectionIndexTitles()
            
            addedMembers.removeAtIndex(indexPath.row - 1)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            
            tableView.endUpdates()
        }
    }
    
    
    /*
     // Override to support rearranging the table view.
     override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            numberOfAddedUsers += 1
            addedMembers.append(filteredUsers[indexPath.row])

            let userToRemove = filteredUsers[indexPath.row]
            if let index = allUsers.indexOf(userToRemove) {
                allUsers.removeAtIndex(index)
            }
            tableView.beginUpdates()
            filteredUsers.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            
            let index = NSIndexPath(forRow: numberOfAddedUsers, inSection: 0)
            tableView.insertRowsAtIndexPaths([index], withRowAnimation: .Bottom)
            tableView.endUpdates()
        }
    }
    
    func showAlert() {
        let alert = UIAlertController(title: "Error Creating Group", message: "Please specify a group name, and at least 1 member.", preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
        alert.addAction(cancelAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func becameFirstResponder() {
        UserController.fetchAllUsers { (users) in
            guard let id = LoginPersistenceController.loggedInUserID else { return }
            
            if self.allUsers.count > 0 {
                self.allUsers.removeAll()
                var indexPaths = [NSIndexPath]()
                for i in 0..<self.filteredUsers.count {
                    indexPaths.append(NSIndexPath(forRow: i, inSection: 1))
                }
                self.filteredUsers.removeAll()
                self.tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: .Right)
            }
            
            self.allUsers = users.filter({$0.id != id})
            for user in self.addedMembers {
                self.allUsers = self.allUsers.filter({$0.id != user.id})
            }
            self.filteredUsers = self.allUsers
            self.filteredUsers = self.filteredUsers.sort({$0.displayName < $1.displayName})
            self.allUsers = self.allUsers.sort({$0.displayName < $1.displayName})

            
            var indexPaths: [NSIndexPath] = [NSIndexPath]()
            for i in 0..<self.allUsers.count {
                indexPaths.append(NSIndexPath(forRow: i, inSection: 1))
            }
            self.tableView.reloadSectionIndexTitles()
            self.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Left)
        }
    }
    
    func resignedFirstResponder() {
        var indexPaths = [NSIndexPath]()
        for i in 0..<filteredUsers.count {
            indexPaths.append(NSIndexPath(forItem: i, inSection: 1))
        }
        filteredUsers = [User]()
        
        tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
    }
    
    func newText(text: String) {
        let lcText = text.lowercaseString
        let searchArray = lcText.componentsSeparatedByString(" ").filter({!$0.isEmpty})
        if searchArray.isEmpty {
            tableView.beginUpdates()
            for i in 0..<allUsers.count {
                let user = allUsers[i]
                if let _ = filteredUsers.indexOf(user) {
                } else {
                    filteredUsers.append(user)
                    let index = NSIndexPath(forRow: filteredUsers.count - 1, inSection: 1)
                    tableView.insertRowsAtIndexPaths([index], withRowAnimation: .Left)
                }
            }
            tableView.endUpdates()
        } else {
            var userToRemove = [User]()
            var usersToAdd = [User]()
            for i in 0..<allUsers.count {
                let user = allUsers[i]
                var foundMatch = false
                for searchTerm in searchArray {
                    if user.displayName.lowercaseString.containsString(searchTerm) || user.firstName.lowercaseString.containsString(searchTerm) || user.lastName.lowercaseString.containsString(searchTerm) || user.email.lowercaseString.containsString(searchTerm) {
                        foundMatch = true
                        break
                    }
                }
                if foundMatch {
                    usersToAdd.append(allUsers[i])
                } else {
                    userToRemove.append(allUsers[i])
                }
            }
            
            tableView.beginUpdates()
            
            for user in usersToAdd {
                if let _ = filteredUsers.indexOf(user) {
                }else {
                    filteredUsers.append(user)
                    let index = NSIndexPath(forItem: filteredUsers.count - 1, inSection: 1)
                    tableView.insertRowsAtIndexPaths([index], withRowAnimation: .Left)
                }
            }
            
            var usersToRemoveInFilteredArray = [User]()
            for user in userToRemove {
                if let index = filteredUsers.indexOf(user) {
                    usersToRemoveInFilteredArray.append(user)
                    let indexToRemove = NSIndexPath(forRow: Int(index), inSection: 1)
                    tableView.deleteRowsAtIndexPaths([indexToRemove], withRowAnimation: .Bottom)
                }
            }
            
            for user in usersToRemoveInFilteredArray {
                if let index = filteredUsers.indexOf(user) {
                    filteredUsers.removeAtIndex(index)
                }
            }
            tableView.endUpdates()
        }
    
    }
    
//    override func scrollViewDidScroll(scrollView: UIScrollView) {
//        let indexPath = tableView.indexPathsForVisibleRows
//        if let indexPath = indexPath?.first {
//            if indexPath.section == 0 && indexPath.row == numberOfAddedUsers + 1 {
//                let reloadIndexPath = NSIndexPath(forRow: numberOfAddedUsers + 1, inSection: 0)
//                let toIndexPath = NSIndexPath(forRow: numberOfAddedUsers + 1, inSection: 0)
//                if let _ = tableView.cellForRowAtIndexPath(reloadIndexPath) as? CreateButtonTableViewCell {
//                    tableView.moveRowAtIndexPath(reloadIndexPath, toIndexPath: toIndexPath)
//                }
//            }
//        }
//    }
    
    func updateWith(group: Group) {
        self.group = group
        self.title = "Edit Group"
        UserController.fetchMultipleUsersWith(group.userIDs) { (users) in
            guard let id = LoginPersistenceController.loggedInUserID else { return }
            self.addedMembers = users.filter({$0.id != id})
            self.numberOfAddedUsers = self.addedMembers.count
            self.tableView.reloadData()
        }
    }
    
    func saveDeleteUsers(groupsUserIDs: [String], newIds: [String], groupID: String?) {
        for newID in newIds {
            if !groupsUserIDs.contains(newID) {
                //save it to the user
                UserController.fetchUserWith(newID, completion: { (user) in
                    var user = user
                    user?.groupIDs.append(newID)
                    user?.save()
                })
            }
        }
        
        for groupUserID in groupsUserIDs {
            guard let id = LoginPersistenceController.loggedInUserID,
                let groupID = groupID else { return }
            if !newIds.contains(groupUserID) && groupUserID != id {
                //remove it from the user
                UserController.fetchUserWith(groupUserID, completion: { (user) in
                    var user = user
                    if let index = user?.groupIDs.indexOf(groupID) {
                        user?.groupIDs.removeAtIndex(index)
                    }
                    user?.save()
                })
            }
        }
    }
}

