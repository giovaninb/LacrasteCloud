//
//  Parser.swift
//  LacrasteCloud
//
//  Created by Giovani Nícolas Bettoni on 21/06/22.
//

import CloudKit

public protocol Parser {
    func fromRecord(_ record: CKRecord) throws -> LacrasteStorage
    func toRecord(_ storable: LacrasteStorage) throws -> CKRecord
}

public enum ParsingError: Error { case LCParsingError }
