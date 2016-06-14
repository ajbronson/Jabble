//
//  FirebaseController.swift
//  Jabble
//
//  Created by AJ Bronson on 6/8/16.
//  Copyright © 2016 PrecisionCodes. All rights reserved.
//

import Foundation
import Firebase

class FirebaseController {
    
    static let ref = FIRDatabase.database().reference()
}

protocol FirebaseType {
    
    var endpoint: String { get }
    var id: String? { get set }
    var dictionaryCopy: [String: AnyObject] { get }
    
    init?(dictionary: [String: AnyObject], id: String)
    
    mutating func save()
    func delete()
}

extension FirebaseType {
    mutating func save() {
        var newEndpoint = FirebaseController.ref.child(endpoint)
        
        if let id = id {
            newEndpoint = newEndpoint.child(id)
        } else {
            newEndpoint = newEndpoint.childByAutoId()
            self.id = newEndpoint.key
        }
        
        newEndpoint.updateChildValues(dictionaryCopy)
    }
    
    func delete() {
        guard let id = id else { return }
        FirebaseController.ref.child(endpoint).child(id).removeValue()
    }
}