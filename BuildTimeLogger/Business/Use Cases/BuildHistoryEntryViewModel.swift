//
//  BuildHistoryEntryViewModel.swift
//  BuildTimeLogger
//
//  Created by Yoan Bertouin on 23/06/2019.
//  Copyright © 2019 Marcin Religa. All rights reserved.
//

import Foundation

extension Array where Element: BuildHistoryEntryViewModel {

    func toCSVString() -> String {
        return "\(BuildHistoryEntryViewModel.CSVTitles)" + "\n" + map { $0.toCSVString() }.joined(separator: "\n")
    }
}

final class BuildHistoryEntryViewModel {
    let buildTime: Int
    let buildStatus: String
    let schemeName: String
    let date: String
    let time: String
    let username: String
    let hostname: String

    init(buildTime: Int, buildStatus: String, schemeName: String, date: String, time: String, username: String, hostname: String) {
        self.buildTime = buildTime
        self.buildStatus = buildStatus
        self.schemeName = schemeName
        self.date = date
        self.time = time
        self.username = username
        self.hostname = hostname
    }
}

extension BuildHistoryEntryViewModel: Codable { }

extension BuildHistoryEntryViewModel {

    static func create(from buildHistoryEntry: BuildHistoryEntry) -> BuildHistoryEntryViewModel {
        return BuildHistoryEntryViewModel(
            buildTime: buildHistoryEntry.buildTime,
            buildStatus: buildHistoryEntry.buildStatus,
            schemeName: buildHistoryEntry.schemeName,
            date: DateFormatter.ddMMyyyy_slashed.string(from: buildHistoryEntry.date),
            time: DateFormatter.HHmmss_colon.string(from: buildHistoryEntry.date),
            username: buildHistoryEntry.username,
            hostname: buildHistoryEntry.hostname
        )
    }

    static let CSVTitles = "host,user,scheme,date,time,build duration,build Status"

    func toCSVString() -> String {
        return "\(hostname),\(username),\(schemeName),\(date),\(time),\(buildTime),\(buildStatus)"
    }
}
