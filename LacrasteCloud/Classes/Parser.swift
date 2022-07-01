//
//  Parser.swift
//  LacrasteCloud
//
//  Created by Giovani Nícolas Bettoni on 21/06/22.
//

import CloudKit

public protocol Parser {
    func fromRecord(_ record: CKRecord) throws -> Storable
    func toRecord(_ storable: Storable) throws -> CKRecord
}

public enum ParsingError: Error { case DDCParsingError }
