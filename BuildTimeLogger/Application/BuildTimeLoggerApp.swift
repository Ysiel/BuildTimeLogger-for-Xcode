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
        switch CommandLineAnalyzer.process(args: CommandLine.arguments) {

        case .save(let scheme, let url): save(scheme, to: url)
        case .fetch(let url, let format): fetch(from: url, toOutputUsing: format)
        case .help(let section): printHelp(section)
        case .error(let section): printError(from: section)
        }
	}
}

private extension BuildTimeLoggerApp {

    func save(_ scheme: String, to url: String?) {
        print("Updating local build history...")
        guard let entries = useCase.saveNewBuildHistoryEntries(for: scheme) else {
            print("can't find local build history")
            return
        }

        print("displaying notification...")
        NotificationManager.showNotification(message: useCase.buildNotificationMessage())

        if let url = url {
            print("Storing data remotely...")
            useCase.SaveRemotely(entries: entries, to: url)
        }
    }

    func fetch(from url: String, toOutputUsing format: OutputFormat) {
        useCase.retrieveAllEntries(from: url, format: format, success: { outputString in
            print(outputString)
        }, failure: { error in
            print("error: \(error)")
        })
    }

    func printHelp(_ section: HelpSection) {

        switch section {
        case .all:
            print("""
                  usage: buildtimelogger [-h | help]
                                         <command> [<args>]

                  These are list of available commands used in various situations:
                    save    save all build data available locally, display a notification with daily summary and optionally send data to a REST endpoint.
                    fetch   retrieve all data stored in a REST endpoint and output them to console using a specified format

                  See 'buildtimelogger help <command>' to read about a specific subcommand.
                  """)
        case .fetch:
            print("""

                  NAME
                          buildtimelogger-fetch

                  SYNOPSIS
                          buildtimelogger [fetch | -f] <url> <csv | json>

                  DESCRIPTION
                            This command fetch all data stored in a REST endpoint and output them to console using a specified format
                            You have to provide an url where to retrieve data and an output format.
                            This last option can be either csv or json
                  """)
        case .save:
            print("""

                  NAME
                          buildtimelogger-save

                  SYNOPSIS
                          buildtimelogger [save | -s] <scheme name> <url>

                  DESCRIPTION
                            For a given scheme name, this command retrieves builds data found in
                            Xcode derived data folder and save them locally. Afterwards, a notification
                            giving statistics is displayed. Data are summarized for the given scheme name,
                            they are:
                                - latest build time
                                - statistics for the day : total build time, average build time and build count.

                            optionally you can provide an url representing a rest endpoint where
                            the tool will post all build data.
                  """)
        }
    }

    func printError(from section: HelpSection) {
        print("Unexpected command line. please see help for information:\n\n")
        printHelp(section)
    }
}
