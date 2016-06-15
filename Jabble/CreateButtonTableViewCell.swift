//
//  CreateButtonTableViewCell.swift
//  Jabble
//
//  Created by AJ Bronson on 6/10/16.
//  Copyright © 2016 PrecisionCodes. All rights reserved.
//

import UIKit

class CreateButtonTableViewCell: UITableViewCell, createGroupProtocol {

    var delegate: createGroupProtocol?
    
    @IBAction func createGroupButtonTapped(sender: AnyObject) {
        createGroupTapped()
    }
    
    func createGroupTapped() {
        self.delegate?.createGroupTapped()
    }
    
    @IBOutlet weak var createButtonText: UIButton!
}

protocol createGroupProtocol {
    func createGroupTapped()
}
