//
//  BuildHistoryEntry.swift
//  BuildTimeLogger
//
//  Created by Marcin Religa on 01/03/2017.
//  Copyright © 2017 Marcin Religa. All rights reserved.
//

import Foundation

struct BuildHistoryEntry: Codable {
	let buildTime: Int
	let schemeName: String
	let date: Date
	let username: String
    let hostname: String

    init?(buildTime: Int?, schemeName: String?, date: Date?, username: String?, hostname: String?) {
        guard let buildTime = buildTime, let schemeName = schemeName, let date = date, let username = username else { return nil }

        self.buildTime = buildTime
        self.schemeName = schemeName
        self.date = date
        self.username = username
        self.hostname = hostname ?? ""
    }
}
