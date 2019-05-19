//
//  BuildHistoryEntryRemoteApi.swift
//  BuildTimeLogger
//
//  Created by Yoan Bertouin on 07/04/2019.
//  Copyright © 2019 Marcin Religa. All rights reserved.
//

import Foundation

class FireBaseRestBuildHistoryRemoteApi {

    let remoteStorageURL: URL
    
    init(remoteStorageURL: URL) {
        self.remoteStorageURL = remoteStorageURL
    }
}

extension FireBaseRestBuildHistoryRemoteApi: BuildHistoryRemoteAPI {

    func save(_ entries: [BuildHistoryEntry]) {
        entries.forEach {
            save($0)
        }
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

private extension FireBaseRestBuildHistoryRemoteApi {

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
}
