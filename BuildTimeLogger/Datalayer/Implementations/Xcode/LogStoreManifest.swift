//
//  LogStoreManifest.swift
//  BuildTimeLogger
//
//  Created by Yoan Bertouin on 23/06/2019.
//  Copyright © 2019 Marcin Religa. All rights reserved.
//

import Foundation

struct LogStoreManifest {
    let date: Date
    let url: URL
    private(set) var logs: [XcodeLog] = []

    init(date: Date, url: URL) {
        self.date = date
        self.url = url

        initializeLogs()
    }
}

private extension LogStoreManifest {

    mutating func initializeLogs() {
        let path = url.appendingPathComponent("Logs/Build/LogStoreManifest.plist").path
        guard let logsData = NSDictionary(contentsOfFile: path)?["logs"] as? [String: AnyObject] else { return }

        logs = logsData.values.compactMap {
            XcodeLog(
                schemeName: $0["schemeIdentifier-schemeName"] as? String,
                status: $0["highLevelStatus"] as? String,
                timeStartedRecording: $0["timeStartedRecording"] as? NSNumber,
                timeStoppedRecording: $0["timeStoppedRecording"] as? NSNumber
            )
        }
    }
}
