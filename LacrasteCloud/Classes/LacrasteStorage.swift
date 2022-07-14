//
//  Storable.swift
//  LacrasteCloud
//
//  Created by Giovani Nícolas Bettoni on 21/06/22.
//

import CloudKit

public protocol LacrasteStorage {
    
    static var reference: String { get }
    static var parser: Parser { get }
    
    var recordName: String? { get }
}
