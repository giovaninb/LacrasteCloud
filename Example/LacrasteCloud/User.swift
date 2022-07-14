//
//  User.swift
//  LacrasteCloud_Example
//
//  Created by Giovani Nícolas Bettoni on 07/07/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import CloudKit
import LacrasteCloud

struct User: LacrasteStorage {
    
    static var reference: String = "User"
    static var parser: Parser = UserParser()
    
    var recordName: String?
    
}
