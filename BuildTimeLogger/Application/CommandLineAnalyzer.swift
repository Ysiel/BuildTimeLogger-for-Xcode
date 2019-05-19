//
//  CommandLineAnalyzer.swift
//  BuildTimeLogger
//
//  Created by Yoan Bertouin on 19/05/2019.
//

import Foundation

//TODO: struct shared with use case. Not a good thing
enum OutputFormat: String {
    case csv
    case json
}

enum HelpSection: String {
    case all
    case fetch
    case save
}

enum Action {
    case save(String, String?)
    case fetch(String, OutputFormat)
    case help(HelpSection)
    case error(HelpSection)
}

class CommandLineAnalyzer {

    static func process(args: [String]) -> Action {
        //note: first arg is always current path
        guard args.count > 1 else { return .error(.all) }

        return analyze(
            verb: args[1],
            options: args.count == 2 ? [] : Array(args[2...])
        )
    }
}

private extension CommandLineAnalyzer {

    static func analyze(verb: String, options: [String]) -> Action {

        switch verb.lowercased() {
        case "save", "-s":
            guard options.count < 3 else { return .error(.save) }
            return options.count == 2 ? .save(options[0], options[1]): .save(options[0], nil)
        case "fetch", "-f":
            guard options.count == 2 else { return .error(.fetch) }
            guard let format = OutputFormat(rawValue: options[1].lowercased()) else {  return .error(.fetch) }
            return .fetch(options[0], format)
        case "help", "-h":
            if options.count == 0 { return .help(.all) }
            if options.count > 1 { return .error(.all) }
            guard let section = HelpSection(rawValue: options[0].lowercased()) else {  return .help(.all) }
            return .help(section)
        default:
            return .help(.all)
        }
    }
}
