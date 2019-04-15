//
//  DateFormatter+Customs.swift
//  BuildTimeLogger
//
//  Created by Yoan Bertouin on 15/04/2019.
//  Copyright © 2019 Marcin Religa. All rights reserved.
//

import Foundation


extension DateFormatter {
    static let ddMMyyyy_HHmmss_slashed: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
//        formatter.calendar = Calendar(identifier: .iso8601)
//        formatter.timeZone = /*TimeZone.autoupdatingCurrent*/  TimeZone(secondsFromGMT: -120)
//        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    static let yyyyMMddHHmmss_timezoned_dashed: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        //        formatter.calendar = Calendar(identifier: .iso8601)
        //        formatter.timeZone = /*TimeZone.autoupdatingCurrent*/  TimeZone(secondsFromGMT: -120)
        //        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}

