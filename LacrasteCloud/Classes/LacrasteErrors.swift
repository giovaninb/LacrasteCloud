//
//  LacrasteErrors.swift
//  LacrasteCloud
//
//  Created by Giovani Nícolas Bettoni on 20/06/22.
//

import Foundation

public enum LacrasteErrors: LocalizedError {
        
    case LCDataRetrieval
    case LCDataInsertion
    case LCDataRemoval
    case LCDataUpdate
    case LCNullReference
    case LCNullRecord
    case LCNullReturn
    case LCParsingFailure

    public var errorDescription: String? {
        switch self {
        case .LCDataRetrieval: return NSLocalizedString("Could not retrieve data from storage.", comment: "Error")
        case .LCDataInsertion: return NSLocalizedString("Could not insert data into storage.", comment: "Error")
        case .LCDataRemoval: return NSLocalizedString("Could not remove data from storage.", comment: "Error")
        case .LCDataUpdate: return NSLocalizedString("Could not update data from storage.", comment: "Error")
        case .LCNullReference: return NSLocalizedString("Could not work with a null resource ID.", comment: "Error")
        case .LCNullRecord: return NSLocalizedString("Could not work with a null record.", comment: "Error")
        case .LCNullReturn: return NSLocalizedString("Storage returned null for the operation.", comment: "Error")
        case .LCParsingFailure: return NSLocalizedString("Could not parse CKRecord to object.", comment: "Error")
        }
    }
}

