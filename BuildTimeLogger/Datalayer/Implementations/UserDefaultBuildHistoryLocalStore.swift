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

private struct BuildHistoryEntryUserDefaultEntity {
    let buildTime: Int?
    let buildStatus: String?
    let schemeName: String?
    let date: Date?
    let username: String?
    let hostname: String?
}

extension BuildHistoryEntryUserDefaultEntity: Codable { }

private extension BuildHistoryEntryUserDefaultEntity {
    static func create(from buildHistoryEntry: BuildHistoryEntry) -> BuildHistoryEntryUserDefaultEntity {
        return BuildHistoryEntryUserDefaultEntity(
            buildTime: buildHistoryEntry.buildTime,
            buildStatus: buildHistoryEntry.buildStatus,
            schemeName: buildHistoryEntry.schemeName,
            date: buildHistoryEntry.date,
            username: buildHistoryEntry.username,
            hostname: buildHistoryEntry.hostname)
    }

    func createBuildHistoryEntryEntity() -> BuildHistoryEntry? {
        return BuildHistoryEntry(
            buildTime: self.buildTime,
            buildStatus: self.buildStatus,
            schemeName: self.schemeName,
            date: self.date,
            username: self.username,
            hostname: self.hostname
        )
    }
}

class UserDefaultBuildHistoryLocalStore { }

extension UserDefaultBuildHistoryLocalStore: BuildHistoryLocalStore {

    func save(entries: [BuildHistoryEntry]) {
        guard let encodedEntries = try? JSONEncoder().encode(retrieveAllEntries() + entries) else { return }

        UserDefaults.standard.setValue(
            encodedEntries,
            forKey: UserSettings.BuildHistory
        )
    }

    func retrieveAllEntries() -> [BuildHistoryEntry] {
        guard let data = UserDefaults.standard.data(forKey: UserSettings.BuildHistory) else { return [] }

        return ((try? JSONDecoder().decode([BuildHistoryEntryUserDefaultEntity].self, from: data)) ?? []).compactMap { $0.createBuildHistoryEntryEntity() }
    }

    func retrieveAllEntries(for scheme: String) -> [BuildHistoryEntry] {
        return retrieveAllEntries().filter { $0.schemeName.caseInsensitiveCompare(scheme) == .orderedSame }
    }
}

