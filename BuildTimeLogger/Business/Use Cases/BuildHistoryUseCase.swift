//
//  BuildHistoryUseCase.swift
//  BuildTimeLogger
//
//  Created by Yoan Bertouin on 04/04/2019.
//  Copyright © 2019 Marcin Religa. All rights reserved.
//

import Foundation

// UC 1 : notif only (aka save local)
// UC 2 : notif + saveRemote
// UC 3: fetch remote

class BuildHistoryUseCase {

    private let builder: BuildTool
    private let remoteApi: BuildHistoryRemoteAPI
    private let dataStore: BuildHistoryLocalStore

    init(dataStore: BuildHistoryLocalStore, remoteApi: BuildHistoryRemoteAPI, builder: BuildTool) {
        self.dataStore = dataStore
        self.remoteApi = remoteApi
        self.builder = builder
    }

    func saveLastBuildHistoryEntry() -> BuildHistoryEntry? {
        guard let lastEntry = builder.retrieveLastBuildHistoryEntry() else { return nil }   // TODO: boaf
        dataStore.save(entry: lastEntry)
        return lastEntry
    }

    func buildNotificationMessage() -> String {
        // Retrieve all entries from NSUSERDEFAULT for today
        let entries = dataStore
            .retrieveAllEntries()
            .filter {
                Calendar.current.isDateInToday($0.date)
        }
        // Calculate intermediate values
        let totalTime = entries.reduce(0) { $0 + $1.buildTime }
        let mostRecentEntry = entries.max(by: { $0.date > $1.date })
        let numberOfBuildsToday = entries.count

        return String(
            format: "current          %@\ntotal today    %@ / avg %@ / %i builds",
            TimeFormatter.format(time: mostRecentEntry!.buildTime),         // Latest build time
            TimeFormatter.format(time: totalTime),                          // Total build time for today
            TimeFormatter.format(time: totalTime / numberOfBuildsToday),    // Average build time for today
            entries.count                                                   // builds count for today
        )
    }

    func SaveRemotely(entry: BuildHistoryEntry) {
        // send entry to REMOTE for saving
        remoteApi.save(entry)
    }

    func retrieveAllEntries(success: @escaping (String) -> Void, failure: @escaping (Error) -> Void) {
        // retrieve all entries from REMOTE
        return remoteApi.retrieveAllEntries { result in
            switch result {
            case .success(let entries):
                success(entries.jsonString)
            case .failure(let error):
                failure(error)
            }
        }
    }
}
