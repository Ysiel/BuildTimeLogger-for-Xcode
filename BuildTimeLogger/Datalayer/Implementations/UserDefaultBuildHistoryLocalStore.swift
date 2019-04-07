//
//  BuildHistoryEntryUserSessionLocalStore.swift
//  BuildTimeLogger
//
//  Created by Yoan Bertouin on 07/04/2019.
//  Copyright © 2019 Marcin Religa. All rights reserved.
//

import Foundation

private enum UserSettings {
    static let BuildHistory = "buildhistoryentries"
}

class UserDefaultBuildHistoryLocalStore {}

extension UserDefaultBuildHistoryLocalStore: BuildHistoryLocalStore {

    func save(entry: BuildHistoryEntry) {
        guard let encodedEntries = try? JSONEncoder().encode(retrieveAllEntries() + [entry]) else { return }

        UserDefaults.standard.setValue(
            encodedEntries,
            forKey: UserSettings.BuildHistory
        )
    }

    func retrieveAllEntries() -> [BuildHistoryEntry] {
        guard let data = UserDefaults.standard.data(forKey: UserSettings.BuildHistory) else { return [] }

        return (try? JSONDecoder().decode([BuildHistoryEntry].self, from: data)) ?? []
    }

}
