//
//  BuildHistoryUseCase.swift
//  BuildTimeLogger
//
//  Created by Yoan Bertouin on 04/04/2019.
//  Copyright © 2019 Marcin Religa. All rights reserved.
//

import Foundation

class BuildHistoryUseCase {

    private let builder: BuildTool
    private let makeRemoteApi: ((String) -> BuildHistoryRemoteAPI)
    private let dataStore: BuildHistoryLocalStore

    init(makeRemoteApi: @escaping ((String) -> BuildHistoryRemoteAPI), dataStore: BuildHistoryLocalStore, builder: BuildTool) {
        self.dataStore = dataStore
        self.makeRemoteApi = makeRemoteApi
        self.builder = builder
    }

    func saveNewBuildHistoryEntries(for scheme: String) -> [BuildHistoryEntry]? {
        // retrieve entries from builder tool
        let entries = builder.retrieveBuildHistoryEntries(for: scheme)
        // determine new entries regarding stored data
        let newEntries = Array(Set(entries).subtracting(dataStore.retrieveAllEntries()))
        // add new data to store
        dataStore.save(entries: newEntries)
        //return them
        return newEntries
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
        let mostRecentEntry = entries.max(by: { $0.date < $1.date })
        let numberOfBuildsToday = entries.count

        return String(
            format: "current          %@\ntotal today    %@ / avg %@ / %i builds",
            TimeFormatter.format(time: mostRecentEntry!.buildTime),         // Latest build time
            TimeFormatter.format(time: totalTime),                          // Total build time for today
            TimeFormatter.format(time: totalTime / numberOfBuildsToday),    // Average build time for today
            entries.count                                                   // builds count for today
        )
    }

    func SaveRemotely(entries: [BuildHistoryEntry], to url: String) {
        // send entry to REMOTE for saving
        makeRemoteApi(url).save(entries)
    }

    func retrieveAllEntries(from url: String, format: OutputFormat, success: @escaping (String) -> Void, failure: @escaping (Error) -> Void) {
        // retrieve all entries from REMOTE
        return makeRemoteApi(url).retrieveAllEntries { result in
            switch result {
            case .success(let entries):
                let formattedString: String = {
                    switch format {
                    case .json:
                        return entries
                            .map { BuildHistoryEntryViewModel.create(from: $0) }
                            .jsonString(encoder: JSONEncoder())
                    case .csv:
                        return entries
                            .map { BuildHistoryEntryViewModel.create(from: $0) }
                            .toCSVString()
                    }
                }()

                success(formattedString)
            case .failure(let error):
                failure(error)
            }
        }
    }
}
