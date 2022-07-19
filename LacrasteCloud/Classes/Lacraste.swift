//
//  Lacraste.swift
//  LacrasteCloud
//
//  Created by Giovani Nícolas Bettoni on 21/06/22.
//

import Foundation
import CloudKit

public struct Lacraste {
    
    /// Returns an CKRecordID for the given recordName
    /// - Parameter completion: Result object containing the user icloud ID or an error
    public static func id(from recordName: String) -> CKRecord.ID {
        return CKRecord.ID(recordName: recordName)
    }
    
    /// Returns a record for the passing Storage object. If the objects has a recordName, it will be preserved.
    /// - Parameter storage: Result CKRecord object from the Storage Object
    public static func record<T: LacrasteStorage>(from storage: T) -> CKRecord {
        
        let record: CKRecord
        
        if let recordName = storage.recordName {
            record = CKRecord(recordType: T.reference, recordID: CKRecord.ID(recordName: recordName))
        } else {
            record = CKRecord(recordType: T.reference)
        }
        return record
    }
    
    /// Returns the current user icloud ID
    /// - Parameter completion: Result object containing the user icloud ID or an error
    public static func getUserRecordID(customContainer: String? = nil, _ completion: @escaping (Result<CKRecord.ID, Error>) -> Void) {
        
        let container: CKContainer
        if let customContainer = customContainer { container = CKContainer(identifier: customContainer) }
        else { container = CKContainer.default() }
        
        container.fetchUserRecordID { (result, error) in
            
            if error != nil {
                completion(.failure(LacrasteErrors.DDCDataRetrieval))
                return
            }
            
            guard let result = result else {
                completion(.failure(LacrasteErrors.DDCNullReturn))
                return
            }
            
            completion(.success(result))
            
        }
    }
    
    /// Fetch all records of T owned by current user
    /// - Parameters:
    ///   - storageType: Which database to perform the query
    ///   - completion: Result object containing all fetched records or an error
    public static func fetchRecordsByUser<T: LacrasteStorage>(storageType: LacrasteType = .privateStorage(), _ completion: @escaping (Result<[T], Error>) -> Void) {
        
        getUserRecordID(customContainer: storageType.container) { (result) in
            switch result {
            case .success(let recordID):
                let query = CKQuery(
                    recordType: T.reference,
                    predicate: NSPredicate(format: "creatorUserRecordID == %@", recordID)
                )
                
                storageType.database.perform(query, inZoneWith: nil) {
                    results, error in
                    
                    if error != nil {
                        completion(.failure(LacrasteErrors.DDCDataRetrieval))
                        return
                    }
                    
                    guard let results = results else {
                        completion(.failure(LacrasteErrors.DDCNullReturn))
                        return
                    }
                    
                    var values: [T] = []
                    for record in results {
                        guard let value = (try? T.parser.fromRecord(record)) as? T
                        else {
                            completion(.failure(LacrasteErrors.DDCParsingFailure))
                            return
                        }
                        values.append(value)
                    }
                    
                    completion(.success(values))
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Fetch records using a predicate String
    /// - Parameters:
    ///   - storageType: Which database to perform the query
    ///   - completion: Result object containing all fetched records or an error
    ///   - predicate: Predicate string
    public static func get<T: LacrasteStorage>(storageType: LacrasteType = .privateStorage(), predicate: NSPredicate,  _ completion: @escaping (Result<[T], Error>) -> Void) {
        
        let query = CKQuery(
            recordType: T.reference,
            predicate: predicate
        )
        
        storageType.database.perform(query, inZoneWith: nil) {
            results, error in
            
            if error != nil {
                completion(.failure(LacrasteErrors.DDCDataRetrieval))
                return
            }
            
            guard let results = results else {
                completion(.failure(LacrasteErrors.DDCNullReturn))
                return
            }
            
            var values: [T] = []
            for record in results {
                guard let value = (try? T.parser.fromRecord(record)) as? T
                else {
                    completion(.failure(LacrasteErrors.DDCParsingFailure))
                    return
                }
                
                values.append(value)
            }
            
            completion(.success(values))
        }
    }
    
    /// Fetch all records of L
    /// - Parameters:
    ///   - storageType: Which database to perform the query
    ///   - completion: Result object containing all fetched records or an error
    public static func getAll<T: LacrasteStorage>(storageType: LacrasteType = .privateStorage(), _ completion: @escaping (Result<[T], Error>) -> Void) {
        
        let query = CKQuery(recordType: T.reference, predicate: NSPredicate(value: true))
        
        storageType.database.perform(query, inZoneWith: nil) { results, error in
            
            if error != nil {
                completion(.failure(LacrasteErrors.DDCDataRetrieval))
                return
            }
            
            guard let result = results
            else {
                completion(.failure(LacrasteErrors.DDCNullReturn))
                return
            }
            
            
            var values: [T] = []
            for record in result {
                guard let value = (try? T.parser.fromRecord(record)) as? T
                else {
                    completion(.failure(LacrasteErrors.DDCParsingFailure))
                    return
                }
                values.append(value)
            }
            
            completion(.success(values))
        }
    }
    
    /// Fetch all records of L - without CloudKit default results limitation
    /// - Parameters:
    ///   - storageType: Which database to perform the query
    ///   - completion: Result object containing all fetched records or an error
    public static func getAllWithoutLimit<T: LacrasteStorage>(storageType: LacrasteType = .privateStorage(), _ completionHandler: @escaping (Result<[T], Error>) -> Void) {
        var listOfRecords: [T] = [] // A place to store the items as we get them
        
        let query = CKQuery(recordType: T.reference, predicate: NSPredicate(value: true))
        let queryOperation = CKQueryOperation(query: query)
        
        // As we get each record, lets store them in the array
        queryOperation.recordFetchedBlock = { record in
            guard let value = (try? T.parser.fromRecord(record)) as? T
            else {
                completionHandler(.failure(LacrasteErrors.DDCParsingFailure))
                return
            }
            listOfRecords.append(value)
        }
        
        // Have another closure for when the download is complete
        queryOperation.queryCompletionBlock = { cursor, error in
            if error != nil {
                completionHandler(.failure(LacrasteErrors.DDCDataRetrieval))
            } else {
                completionHandler(.success(listOfRecords))
            }
        }
        
        storageType.database.add(queryOperation)
    }
    
    /// Fetch the record with the ID
    /// - Parameters:
    ///   - storageType: Which database to perform the query
    ///   - recordID: The UUID of the record in the database
    ///   - completion: Result object containing the fetched record or an error
    public static func get<T: LacrasteStorage>(storageType: LacrasteType = .privateStorage(), recordName: String, _ completion: @escaping (Result<T, Error>) -> Void) {
                
        let recordID = CKRecord.ID(recordName: recordName)
        storageType.database.fetch(withRecordID: recordID) { result, error in
            
            if error != nil {
                completion(.failure(LacrasteErrors.DDCDataRetrieval))
                return
            }
            
            guard let record = result
            else {
                completion(.failure(LacrasteErrors.DDCNullReturn))
                return
            }
            
            guard let value = (try? T.parser.fromRecord(record)) as? T
            else {
                completion(.failure(LacrasteErrors.DDCParsingFailure))
                return
            }
            completion(.success(value))
        }
    }
    
    /// Create a record in the database
    /// - Parameters:
    ///   - storageType: Which database to perform the query
    ///   - storage: The Storage object to  e inserted
    ///   - completion: Result object containing the created record  or an error
    public static func create<T: LacrasteStorage>(storageType: LacrasteType = .privateStorage(), _ storage: T, _  completion: @escaping (Result<T, Error>) -> Void) {
        
        guard let record = try? T.parser.toRecord(storage)
        else {
            return completion(.failure(LacrasteErrors.DDCParsingFailure))
        }

        storageType.database.save(record) { (savedRecord, error) in
            
            if error != nil {
                completion(.failure(LacrasteErrors.DDCDataInsertion))
                return
            }
            
            guard let savedRecord = savedRecord
            else {
                completion(.failure(LacrasteErrors.DDCNullReturn))
                return
            }
            
            guard let value = (try? T.parser.fromRecord(savedRecord)) as? T
            else {
                completion(.failure(LacrasteErrors.DDCParsingFailure))
                return
            }
            
            completion(.success(value))
        }
    }
    
    /// Updates a record in the database
    /// - Parameters:
    ///   - storageType: Which database to perform the query
    ///   - storage: The Storage object to  e updated
    ///   - completion: Result object containing the updated record or an error
    public static func update<T: LacrasteStorage>(storageType: LacrasteType = .privateStorage(), _ storage: T, _  completion: @escaping (Result<String, Error>) -> Void) {
        
        guard let record = try? T.parser.toRecord(storage)
        else {
            completion(.failure(LacrasteErrors.DDCParsingFailure))
            return
        }
                
        let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        operation.savePolicy = .allKeys
        
        operation.modifyRecordsCompletionBlock = { (updatedRecords, _, error) in
            
            if error != nil {
                completion(.failure(LacrasteErrors.DDCDataUpdate))
                return
            }
            
            guard let recordName = updatedRecords?.first?.recordID.recordName
            else {
                completion(.failure(LacrasteErrors.DDCNullReturn))
                return
            }
            
            completion(.success(recordName))
        }
        
        storageType.database.add(operation)
    }
    
    /// Removes a record from the database
    /// - Parameters:
    ///   - storageType: Which database to perform the query
    ///   - recordID: The UUID of the record in the database
    ///   - completion: Result object the deleted record ID or an error
    public static func remove(storageType: LacrasteType = .privateStorage(), _ recordName: String, completion: @escaping (Result<String, Error>) -> Void) {
                
        let recordID = CKRecord.ID(recordName: recordName)
        storageType.database.delete(withRecordID: recordID) { (recordID, error) in
            
            if error != nil {
                completion(.failure(LacrasteErrors.DDCDataRemoval))
                return
            }
            
            guard let recordID = recordID
            else {
                completion(.failure(LacrasteErrors.DDCNullReturn))
                return
            }
            completion(.success(recordID.recordName))
        }
    }
    
    /// Removes multiple records from the database
    /// - Parameters:
    ///   - storageType: Which database to perform the query
    ///   - recordIDs: The UUID's in the database
    ///   - completion: Result object the deleted record ID's or an error
    public static func remove(storageType: LacrasteType = .privateStorage(), _ recordNames: [String], completion: @escaping (Result<[String], Error>) -> Void) {
        
        let recordIDs = recordNames.map({ CKRecord.ID(recordName: $0) })
        let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: recordIDs)
        
        operation.modifyRecordsCompletionBlock = { (_, deletedRecordIDs, error) in
            
            if error != nil {
                completion(.failure(LacrasteErrors.DDCDataRemoval))
                return
            }
            
            guard let recordIDs = deletedRecordIDs
            else {
                completion(.failure(LacrasteErrors.DDCNullReturn))
                return
            }
            
            completion(.success(recordIDs.map({ $0.recordName })))
        }
        
        storageType.database.add(operation)
    }
    
    /// Removes all records of type L
    /// - Parameters:
    ///   - storageType: Which database to perform the query
    ///   - type: The type of the record
    ///   - completion: Result object the deleted record ID's or an error
    public static func removeAll<T: LacrasteStorage>(storageType: LacrasteType = .privateStorage(), type: T.Type, completion: @escaping (Result<[String], Error>) -> Void) {
        
        getAll(storageType: storageType) { (result: Result<[T], Error>) in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let values):
                guard let recordNames = values.map({ $0.recordName }) as? [String]
                else {
                    completion(.failure(LacrasteErrors.DDCNullRecord))
                    return
                }
                                
                remove(storageType:storageType, recordNames) { result in
                    switch result {
                    case .failure(let error):
                        completion(.failure(error))
                    case .success(let recordIDs):
                        completion(.success(recordIDs))
                    }
                }
            }
        }
    }
    
    /// Removes all records of type L owned by current user
    /// - Parameters:
    ///   - storageType: Which database to perform the query
    ///   - type: The type of the record
    ///   - completion: Result object the deleted record ID's or an error
    public static func removeAllbyUser<T: LacrasteStorage>(storageType: LacrasteType = .privateStorage(), type: T.Type, completion: @escaping (Result<[String], Error>) -> Void) {
        
        fetchRecordsByUser(storageType: storageType) { (result: Result<[T], Error>) in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let values):
                guard let recordNames = values.map({ $0.recordName }) as? [String]
                else {
                    completion(.failure(LacrasteErrors.DDCNullRecord))
                    return
                }
                                
                remove(storageType:storageType, recordNames) { result in
                    switch result {
                    case .failure(let error):
                        completion(.failure(error))
                    case .success(let recordIDs):
                        completion(.success(recordIDs))
                    }
                }
            }
        }
    }
    
    /// Remove records using a predicate String
    /// - Parameters:
    ///   - storageType: Which database to perform the query
    ///   - completion: Result object containing all deleted record ID's or an error
    ///   - predicate: Predicate string
    public static func remove<T: LacrasteStorage>(storageType: LacrasteType = .privateStorage(), type: T.Type, predicate: NSPredicate,  _ completion: @escaping (Result<[String], Error>) -> Void) {
        
        Lacraste.get(storageType: storageType, predicate: predicate) {
            (result: Result<[T], Error>) in
            
            switch result {
            case.failure(let error):
                completion(.failure(error))
            case .success(let values):
                guard let recordNames = values.map({ $0.recordName }) as? [String]
                else {
                    completion(.failure(LacrasteErrors.DDCNullRecord))
                    return
                }
                                
                remove(storageType:storageType, recordNames) { result in
                    switch result {
                    case .failure(let error):
                        completion(.failure(error))
                    case .success(let recordIDs):
                        completion(.success(recordIDs))
                    }
                }
                
                completion(.success(recordNames))
            }
        }
    }
}



