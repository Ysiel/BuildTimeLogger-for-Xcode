//
//  XcodeBuilder.swift
//  BuildTimeLogger
//
//  Created by Yoan Bertouin on 07/04/2019.
//  Copyright © 2019 Marcin Religa. All rights reserved.
//

import Foundation

class XcodeBuilder { }

extension XcodeBuilder: BuildTool {

    func retrieveLastBuildHistoryEntry() -> BuildHistoryEntry? {

        return XcodeBuilder
            .derivedData()
            .compactMap {
                XcodeDatabase(
                    fromPath: $0.url.appendingPathComponent("Logs/Build/LogStoreManifest.plist").path
                )
            }
            .sorted(
                by: { $0.modificationDate > $1.modificationDate }
        )
        .first?
        .createBuildHistoryEntry()
    }
}

private extension XcodeBuilder {

    static func derivedData() -> [File] {

        let url: URL = {
            if let libraryFolder = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first {
                return URL(fileURLWithPath: "\(libraryFolder)/Developer/Xcode/DerivedData")
            }
            return URL(fileURLWithPath: "")
        }()



        return listFolders(at: url)
            .compactMap { (url) -> File? in

                guard let properties = try? FileManager.default.attributesOfItem(atPath: url.path),
                    let modificationDate = properties[FileAttributeKey.modificationDate] as? Date else { return nil}

                guard url.lastPathComponent != "ModuleCache" else { return nil }

                return File(date: modificationDate, url: url)
            }
            .sorted{ $0.date > $1.date }
    }

    static func listFolders(at url: URL) -> [URL] {

        guard let enumerator = FileManager.default.enumerator(
            at: url,
            includingPropertiesForKeys: [
                URLResourceKey.nameKey,
                URLResourceKey.isDirectoryKey
            ],
            options: [
                .skipsHiddenFiles,
                .skipsPackageDescendants,
                .skipsSubdirectoryDescendants
            ],
            errorHandler: nil
            ) else { return [] }

        return enumerator.map{ $0 as! URL }
    }
}

private struct XcodeDatabase {

    let path: String
    let modificationDate: Date
    let key: String
    let schemeName: String
    let timeStartedRecording: Int
    let timeStoppedRecording: Int
    let logUrl: URL
    let buildTime: Int
    let buildDate = Date()
    let username = NSUserName()
    let hostname = Host.current().localizedName ?? ""

    init?(fromPath path: String) {
        guard let data = NSDictionary(contentsOfFile: path)?["logs"] as? [String: AnyObject],
            let key = XcodeDatabase.sortKeys(usingData: data).last?.key,
            let value = data[key] as? [String : AnyObject],
            let schemeName = value["schemeIdentifier-schemeName"] as? String,
            let timeStartedRecording = value["timeStartedRecording"] as? NSNumber,
            let timeStoppedRecording = value["timeStoppedRecording"] as? NSNumber,
            let fileAttributes = try? FileManager.default.attributesOfItem(atPath: path),
            let modificationDate = fileAttributes[FileAttributeKey.modificationDate] as? Date
            else { return nil }

        self.modificationDate = modificationDate
        self.path = path
        self.key = key
        self.schemeName = schemeName
        self.timeStartedRecording = timeStartedRecording.intValue
        self.timeStoppedRecording = timeStoppedRecording.intValue

        logUrl = URL(fileURLWithPath: path).deletingLastPathComponent().appendingPathComponent("\(key).xcactivitylog")
        buildTime = self.timeStoppedRecording - self.timeStartedRecording
    }
}

private extension XcodeDatabase {

    func createBuildHistoryEntry() -> BuildHistoryEntry? {
        return BuildHistoryEntry(
            buildTime: buildTime,
            schemeName: schemeName,
            date: buildDate,
            username: username,
            hostname: hostname
        )
    }

    static func sortKeys(usingData data: [String: AnyObject]) -> [(Int, key: String)] {
        var sortedKeys: [(Int, key: String)] = []
        for key in data.keys {
            if let value = data[key] as? [String: AnyObject],
                let timeStoppedRecording = value["timeStoppedRecording"] as? NSNumber {
                sortedKeys.append((timeStoppedRecording.intValue, key))
            }
        }
        return sortedKeys.sorted{ $0.0 < $1.0 }
    }
}

extension XcodeDatabase : Equatable {}

private func ==(lhs: XcodeDatabase, rhs: XcodeDatabase) -> Bool {
    return lhs.path == rhs.path && lhs.modificationDate == rhs.modificationDate
}

private struct File {
    let date: Date
    let url: URL
}
