//
//  main.swift
//  BuildTimeLogger
//
//  Created by Marcin Religa on 22/02/2017.
//  Copyright © 2017 Marcin Religa. All rights reserved.
//

import Foundation

// Need to wait in the beginning, otherwise without that the app is picking the previous build for some reason.
sleep(1)

let remoteStorageURL: URL = {

    guard CommandLine.arguments.count > 1 else {
        return URL(string: "")!
    }

    return URL(string: CommandLine.arguments[1])!
}()

let app = BuildTimeLoggerApp(
    useCase: BuildHistoryUseCase(
        dataStore: UserDefaultBuildHistoryLocalStore(),
        remoteApi: FireBaseRestBuildHistoryRemoteApi(
            remoteStorageURL: remoteStorageURL
        ),
        builder: XcodeBuilder())
)

app.run()
