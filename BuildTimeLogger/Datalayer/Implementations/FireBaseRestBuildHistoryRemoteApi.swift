//
//  BuildHistoryEntryRemoteApi.swift
//  BuildTimeLogger
//
//  Created by Yoan Bertouin on 07/04/2019.
//  Copyright © 2019 Marcin Religa. All rights reserved.
//

import Foundation

private extension BuildHistoryEntry {

    func encodeToJsonData() -> Data? {
        return try? JSONEncoder().encode(self)
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

        guard let data = entry.encodeToJsonData() else {
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
                let entries = Array((try JSONDecoder().decode([String: BuildHistoryEntry].self, from: data)).values)
                    completion(.success(entries))
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
