//
//  DataParser.swift
//  BuildTimeLogger
//
//  Created by Marcin Religa on 08/03/2017.
//  Copyright © 2017 Marcin Religa. All rights reserved.
//

import Foundation

struct DataParser {

    func parseDetails(data: Data) {
        guard let responseJSON = parseResponse(data: data) else {
            return
        }

        let buildHistory = parse(json: responseJSON).jsonString
        print(buildHistory)

    }

    func parseSummary(data: Data) {
		guard let responseJSON = parseResponse(data: data) else {
			return
		}

		let buildHistory = parse(json: responseJSON)

		let allUsernames = Set(buildHistory.map({ $0.username }))

		for username in allUsernames {

			let buildTimeTotalFormatted = TimeFormatter.format(
                time: totalBuildTime(
                    for: buildHistory.filter({ $0.username == String(username) })
                )
            )

			print("username: \(username)\ntotal build time: \(buildTimeTotalFormatted)\n")
		}
	}

	func buildEntriesFromToday(in buildHistoryData: [BuildHistoryEntry]) -> [BuildHistoryEntry] {
		return buildHistoryData.filter({
			Calendar.current.isDateInToday($0.date)
		})
	}

	func totalBuildTime(for buildHistoryData: [BuildHistoryEntry]) -> Int {
		return buildHistoryData.reduce(0, {
			return $0 + $1.buildTime
		})
	}
}

private extension DataParser {

	func parseResponse(data: Data) -> [String: Any]? {
		do {
			let json = try JSONSerialization.jsonObject(with: data, options: [])

			if let responseData = json as? [String: Any] {
				return responseData
			}
		} catch {
			print("JSON parsing error")
		}

		return nil
	}

	func parse(json: [String: Any]) -> [BuildHistoryEntry] {
		return json.compactMap({
			guard let record = $0.value as? [String: String] else { return nil }

            let schemeName = record[BuildHistoryEntryKey.schemeName.rawValue] ?? ""
            let username = record[BuildHistoryEntryKey.username.rawValue] ?? ""
            let timestamp = TimeInterval(record[BuildHistoryEntryKey.timestamp.rawValue] ?? "") ?? 0
            let buildTime = Int(record[BuildHistoryEntryKey.buildTime.rawValue] ?? "") ?? 0
            let xcodeVersion = record[BuildHistoryEntryKey.xcodeVersion.rawValue] ?? ""

            return BuildHistoryEntry(buildTime: buildTime, schemeName: schemeName, date: Date(timeIntervalSince1970: timestamp), username: username, xcodeVersion: xcodeVersion)
		})
	}
}
