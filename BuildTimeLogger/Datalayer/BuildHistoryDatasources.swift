//
//  BuildHistorydatasources.swift
//  BuildTimeLogger
//
//  Created by Yoan Bertouin on 04/04/2019.
//  Copyright © 2019 Marcin Religa. All rights reserved.
//

import Foundation

enum NetworkError: Error {
    case didFailToFetchData
}

protocol BuildHistoryRemoteAPI {
    func save(_ entries: [BuildHistoryEntry])
    func retrieveAllEntries(completion: @escaping (Result<[BuildHistoryEntry], NetworkError>) -> Void)
}

protocol BuildHistoryLocalStore {
    func save(entries: [BuildHistoryEntry])
    func retrieveAllEntries() -> [BuildHistoryEntry]
    func retrieveAllEntries(for scheme: String) -> [BuildHistoryEntry]
}

protocol BuildTool {
    func retrieveBuildHistoryEntries(for scheme: String) -> [BuildHistoryEntry]
}
