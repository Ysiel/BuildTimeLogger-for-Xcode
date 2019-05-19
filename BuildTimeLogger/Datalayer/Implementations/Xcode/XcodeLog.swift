//
//  XcodeLog.swift
//  BuildTimeLogger
//
//  Created by Yoan Bertouin on 23/06/2019.
//  Copyright © 2019 Marcin Religa. All rights reserved.
//

import Foundation

struct XcodeLog {

    private let timeStartedRecording: Int
    private let timeStoppedRecording: Int

    let schemeName: String
    let status: String
    let duration: Int
    let date: Date

    let username = NSUserName()
    let hostname = Host.current().localizedName ?? ""

    init?(schemeName: String?, status: String?, timeStartedRecording: NSNumber?, timeStoppedRecording: NSNumber?) {
        guard let schemeName = schemeName,
            let status = status,
            let timeStartedRecording = timeStartedRecording,
            let timeStoppedRecording = timeStoppedRecording else { return nil }

        self.schemeName = schemeName
        self.status = status
        self.timeStartedRecording = timeStartedRecording.intValue
        self.timeStoppedRecording = timeStoppedRecording.intValue

        duration = self.timeStoppedRecording - self.timeStartedRecording
        date = Date(timeIntervalSinceReferenceDate: timeStartedRecording.doubleValue)
    }
}

extension XcodeLog {

    func createBuildHistoryEntry() -> BuildHistoryEntry? {
        return BuildHistoryEntry(
            buildTime: duration,
            buildStatus: status,
            schemeName: schemeName,
            date: date,
            username: username,
            hostname: hostname
        )
    }
}
