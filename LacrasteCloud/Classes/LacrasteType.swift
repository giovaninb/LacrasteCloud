//
//  LacrasteType.swift
//  LacrasteCloud
//
//  Created by Giovani Nícolas Bettoni on 20/06/22.
//

import CloudKit

public enum LacrasteType {
    case publicStorage(customContainer: String? = nil)
    case privateStorage(customContainer: String? = nil)
    
    var container: String? {
        switch self {
        case
        .publicStorage(let customContainer),
        .privateStorage(let customContainer):
            
            return customContainer
        }
    }
    
    var database: CKDatabase {
        switch self {
        case .publicStorage(let customContainer):
            if let customContainer = customContainer {
                return CKContainer(identifier: customContainer).publicCloudDatabase
            } else {
                return CKContainer.default().publicCloudDatabase
            }
        case .privateStorage(let customContainer):
            if let customContainer = customContainer {
                return CKContainer(identifier: customContainer).privateCloudDatabase
            } else {
                return CKContainer.default().privateCloudDatabase
            }
        }
    }
}

