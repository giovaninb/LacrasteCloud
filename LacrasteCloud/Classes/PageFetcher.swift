//
//  PageFetcher.swift
//  LacrasteCloud
//
//  Created by Giovani Nícolas Bettoni on 11/08/22.
//

import CloudKit

public typealias PagedCompletion<T: LacrasteStorage> = (Result<(elements: [T], moreRecords: PageFetcher<T>?), Error>) -> Void

public class PageFetcher<T: LacrasteStorage> {

    private let storageType: LacrasteType
    private let cursor: CKQueryOperation.Cursor
    private let numberOfRecords: Int

    init(cursor: CKQueryOperation.Cursor, storageType: LacrasteType, numberOfRecords: Int) {
        self.cursor = cursor
        self.storageType = storageType
        self.numberOfRecords = numberOfRecords
    }

    public func fetchPage<T: LacrasteStorage>(_ completionHandler: @escaping PagedCompletion<T>) {

        var listOfRecords: [T] = [] // A place to store the items as we get them

        let queryOperation = CKQueryOperation(cursor: cursor)
        queryOperation.resultsLimit = numberOfRecords

        // As we get each record, lets store them in the array
        queryOperation.recordFetchedBlock = { record in
            guard let value = (try? T.parser.fromRecord(record)) as? T
            else {
                completionHandler(.failure(LacrasteErrors.LCParsingFailure))
                return
            }
            listOfRecords.append(value)
        }

        // Have another closure for when the download is complete
        queryOperation.queryCompletionBlock = { [self] cursor, error in
            //print(">>>> cursor: \(cursor)")
            if error != nil {
                completionHandler(.failure(LacrasteErrors.LCDataRetrieval))
            } else {
                if let cursor = cursor {
                    let pageFetcher = PageFetcher<T>(cursor: cursor, storageType: storageType, numberOfRecords: numberOfRecords)
                    completionHandler(.success((listOfRecords, pageFetcher)))
                } else {
                    completionHandler(.success((listOfRecords, nil)))
                }
            }
        }

        storageType.database.add(queryOperation)
    }
}
