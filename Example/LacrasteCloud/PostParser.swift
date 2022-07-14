//
//  PostParser.swift
//  LacrasteCloud_Example
//
//  Created by Giovani Nícolas Bettoni on 04/07/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import CloudKit
import LacrasteCloud

class PostParser: Parser {
    
    func fromRecord(_ record: CKRecord) throws -> LacrasteStorage {
        let recordName = record.recordID.recordName
        
        guard let name = record["name"] as? String,
              let simpleDescription = record["simpleDescription"] as? String
        else { throw ParsingError.DDCParsingError }
        
        let post = Post(recordName: recordName, name: name, simpleDescription: simpleDescription)
        return post
    }
    
    func toRecord(_ storable: LacrasteStorage) throws -> CKRecord {
        guard let post = storable as? Post
        else { throw ParsingError.DDCParsingError }
        
        let record = Lacraste.record(from: post)
        record.setValue(post.name, forKey: "name")
        record.setValue(post.simpleDescription, forKey: "simpleDescription")
        return record
    }
    
    
}
