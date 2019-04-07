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
    let xcodeVersion: String
}
