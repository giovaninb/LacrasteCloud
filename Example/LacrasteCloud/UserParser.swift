//
//  UserParser.swift
//  LacrasteCloud_Example
//
//  Created by Giovani Nícolas Bettoni on 07/07/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import CloudKit
import LacrasteCloud

class UserParser: Parser {
    func fromRecord(_ record: CKRecord) throws -> LacrasteStorage {
        let recordName = record.recordID.recordName
        
        let user = User(recordName: recordName)
        return user
    }
    
    func toRecord(_ storable: LacrasteStorage) throws -> CKRecord {
        guard let user = storable as? User
        else { throw ParsingError.LCParsingError }
        
        let record = Lacraste.record(from: user)
        return record
    }
    
    
}
