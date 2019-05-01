//
//  BuildHistoryEntryRemoteApi.swift
//  BuildTimeLogger
//
//  Created by Yoan Bertouin on 07/04/2019.
//  Copyright © 2019 Marcin Religa. All rights reserved.
//

import Foundation

struct BuildHistoryEntryAPIEntity {
    let buildTime: Int?
    let schemeName: String?
    let date: Date?
    let username: String?
    let hostname: String?
}

extension BuildHistoryEntryAPIEntity: Codable { }

private extension BuildHistoryEntryAPIEntity {

    func encodeToJsonData() -> Data? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(DateFormatter.yyyyMMddHHmmss_timezoned_dashed)
        return try? encoder.encode(self)
    }

    static func create(from buildHistoryEntry: BuildHistoryEntry) -> BuildHistoryEntryAPIEntity {
        return BuildHistoryEntryAPIEntity(
            buildTime: buildHistoryEntry.buildTime,
            schemeName: buildHistoryEntry.schemeName,
            date: buildHistoryEntry.date,
            username: buildHistoryEntry.username,
            hostname: buildHistoryEntry.hostname)
    }

    func createBuildHistoryEntryEntity() -> BuildHistoryEntry? {
        return BuildHistoryEntry(
            buildTime: self.buildTime,
            schemeName: self.schemeName,
            date: self.date,
            username: self.username,
            hostname: self.hostname
        )
    }
}

class FireBaseRestBuildHistoryRemoteApi {

    let remoteStorageURL: URL
    
    init(remoteStorageURL: URL) {
        self.remoteStorageURL = remoteStorageURL
    }
}

extension FireBaseRestBuildHistoryRemoteApi: BuildHistoryRemoteAPI {
    func save(_ entry: BuildHistoryEntry) {

        guard let data = BuildHistoryEntryAPIEntity.create(from: entry).encodeToJsonData() else {
            print("can't encode data to JSON")
            return
        }   //TODO: boaf

        let semaphore = DispatchSemaphore(value: 0)
        let request: URLRequest = {
            var newRequest = URLRequest(url: remoteStorageURL)
            newRequest.httpMethod = "POST"
            newRequest.httpBody = data
            return newRequest
        }()

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("error: \(error)")
            }

            semaphore.signal()
        }
        task.resume()
        semaphore.wait();
    }

    func retrieveAllEntries(completion: @escaping (Result<[BuildHistoryEntry], NetworkError>) -> Void) {
        let semaphore = DispatchSemaphore(value: 0)

        let request: URLRequest = {
            var newRequest = URLRequest(url: remoteStorageURL)
            newRequest.httpMethod = "GET"
            return newRequest
        }()

        let task = URLSession.shared.dataTask(with: request) { data, response, error in

            guard let data = data, error == nil else {
                completion(.failure(NetworkError.didFailToFetchData))
                return
            }

            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .formatted(DateFormatter.yyyyMMddHHmmss_timezoned_dashed)
                let entries = Array((try decoder.decode([String: BuildHistoryEntryAPIEntity].self, from: data)).values)
                completion(.success(entries.compactMap { $0.createBuildHistoryEntryEntity() }))
            } catch {
                print(error)
                completion(.failure(NetworkError.didFailToFetchData))
            }

            semaphore.signal()
        }
        task.resume()
        semaphore.wait();
    }

}
