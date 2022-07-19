//
//  Post.swift
//  LacrasteCloud_Example
//
//  Created by Giovani Nícolas Bettoni on 04/07/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import CloudKit
import LacrasteCloud

struct Post: LacrasteStorage {
    
    /// Static attributes
    static var reference: String = "Post"
    static var parser: Parser = PostParser()
    
    ///  attributes
    var recordName: String?
    
    /// Custom attributes
    var name: String
    var simpleDescription: String?
    var image: CKAsset?
}
