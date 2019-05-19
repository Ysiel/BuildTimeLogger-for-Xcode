//
//  BuildHistoryEntryAPIEntity.swift
//  BuildTimeLogger
//
//  Created by Yoan Bertouin on 22/05/2019.
//  Copyright © 2019 Marcin Religa. All rights reserved.
//

import Foundation

final class BuildHistoryEntryAPIEntity {
    let buildTime: Int?
    let buildStatus: String?
    let schemeName: String?
    let date: Date?
    let username: String?
    let hostname: String?

    init(buildTime: Int?, buildStatus: String?, schemeName: String?, date: Date?, username: String?, hostname: String?) {
        self.buildTime = buildTime
        self.buildStatus = buildStatus
        self.schemeName = schemeName
        self.date = date
        self.username = username
        self.hostname = hostname
    }
}

extension BuildHistoryEntryAPIEntity: Codable { }

extension BuildHistoryEntryAPIEntity {

    func encodeToJsonData() -> Data? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(DateFormatter.yyyyMMddHHmmss_timezoned_dashed)
        return try? encoder.encode(self)
    }

    static func create(from buildHistoryEntry: BuildHistoryEntry) -> BuildHistoryEntryAPIEntity {
        return BuildHistoryEntryAPIEntity(
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

extension Array where Element: BuildHistoryEntryAPIEntity {

    func encodeToJsonData() -> Data? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(DateFormatter.yyyyMMddHHmmss_timezoned_dashed)
        return try? encoder.encode(self)
    }
}
