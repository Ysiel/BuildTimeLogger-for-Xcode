//
//  BuildTimeLoggerApp.swift
//  BuildTimeLogger
//
//  Created by Marcin Religa on 01/03/2017.
//  Copyright © 2017 Marcin Religa. All rights reserved.
//

import Foundation

final class BuildTimeLoggerApp {

    private let useCase: BuildHistoryUseCase

    init(useCase: BuildHistoryUseCase ) {
		self.useCase = useCase
	}

	func run() {
		switch CommandLine.arguments.count {
		case 2:
			print("Updating local build history...")
            guard let entry = useCase.saveLastBuildHistoryEntry() else {
                print("can't find local build history")
                return
            }

            print("displaying notification...")
            NotificationManager.showNotification(message: useCase.buildNotificationMessage())

			print("Storing data remotely...")
            useCase.SaveRemotely(entry: entry)

		case 3:
			print("Fetching remote data...")
			useCase.retrieveAllEntries(success: { outputString in
                print(outputString)
            }, failure: { error in
                print("error: \(error)")
            })

		default:
            print("Updating local build history...")
            _ = useCase.saveLastBuildHistoryEntry()

            print("displaying notification...")
            NotificationManager.showNotification(message: useCase.buildNotificationMessage())
		}
	}
}
