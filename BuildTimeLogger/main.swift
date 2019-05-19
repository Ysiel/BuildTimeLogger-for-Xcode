//
//  main.swift
//  BuildTimeLogger
//
//  Created by Marcin Religa on 22/02/2017.
//  Copyright © 2017 Marcin Religa. All rights reserved.
//

import Foundation

func remoteApiFactory(_ urlString: String) -> BuildHistoryRemoteAPI {

    guard let url = URL(string: urlString) else {
        fatalError("incorrect URL")
    }

    return FireBaseRestBuildHistoryRemoteApi(remoteStorageURL: url)
}

sleep(1)    // Need to wait in the beginning, otherwise without that the app is picking the previous build for some reason.

let app = BuildTimeLoggerApp(
    useCase: BuildHistoryUseCase(
        makeRemoteApi: remoteApiFactory,
        dataStore: UserDefaultBuildHistoryLocalStore(),
        builder: XcodeBuilder()
    )
)

app.run()
