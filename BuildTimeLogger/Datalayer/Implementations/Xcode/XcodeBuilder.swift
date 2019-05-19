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

    func retrieveBuildHistoryEntries(for scheme: String) -> [BuildHistoryEntry] {

        return retrieveLogManifests()
            .flatMap { $0.logs }
            .filter { $0.schemeName.caseInsensitiveCompare(scheme) == .orderedSame }
            .compactMap { $0.createBuildHistoryEntry() }
    }
}

private extension XcodeBuilder {

    func retrieveLogManifests() -> [LogStoreManifest] {

        let url: URL = {
            if let libraryFolder = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first {
                return URL(fileURLWithPath: "\(libraryFolder)/Developer/Xcode/DerivedData")
            }
            return URL(fileURLWithPath: "")
        }()

        return listFolders(at: url).compactMap { (url) -> LogStoreManifest? in
            guard let properties = try? FileManager.default.attributesOfItem(atPath: url.path),
                let modificationDate = properties[FileAttributeKey.modificationDate] as? Date else { return nil}

            guard url.lastPathComponent != "ModuleCache" else { return nil }

            return LogStoreManifest(date: modificationDate, url: url)
        }
    }

    /// return all subfolders' path for a given url
    func listFolders(at url: URL) -> [URL] {

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
