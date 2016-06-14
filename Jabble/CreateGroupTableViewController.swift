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
    
    
    var member: String?
    var name: String?
    
    var nameTextField: UITextField?
    var memberTextField: UITextField?
    
    var numberOfAddedUsers = 0
    var allUsers = [User]()
    var filteredUsers = [User]()
    var addedMembers = [User]()
    
    var showUsers = false
    
    
    
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
        guard let user = UserController.currentUser, id = user.id, name = name where name.characters.count > 0 && addedMembers.count > 0  else { showAlert(); return }
        var memberIDs = addedMembers.flatMap({$0.id})
        memberIDs.append(id)
        let group = Group(type: "Closed", kingID: id, name: name, users: memberIDs)
        group.save()
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
    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 && indexPath.row != 0 && indexPath.row != numberOfAddedUsers + 1 && indexPath.row != numberOfAddedUsers + 2 && editingStyle == .Delete {
            numberOfAddedUsers -= 1
            tableView.beginUpdates()
            
            allUsers.append(addedMembers[indexPath.row - 1])
            filteredUsers.append(addedMembers[indexPath.row - 1])
            
            let index = NSIndexPath(forRow: filteredUsers.count - 1, inSection: 1)
            self.tableView.insertRowsAtIndexPaths([index], withRowAnimation: .Left)
            
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
        showUsers = true
        UserController.fetchAllUsers { (users) in
            self.allUsers = users
            self.filteredUsers = users
            
            var indexPaths: [NSIndexPath] = [NSIndexPath]()
            for i in 0...self.allUsers.count - 1 {
                indexPaths.append(NSIndexPath(forRow: i, inSection: 1))
            }
            self.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Left)
        }
    }
    
    func resignedFirstResponder() {
        showUsers = false
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
}

