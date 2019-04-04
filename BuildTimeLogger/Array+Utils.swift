//
//  Array+Utils.swift
//  BuildTimeLogger
//
//  Created by Yoan Bertouin on 04/04/2019.
//  Copyright © 2019 Marcin Religa. All rights reserved.
//

import Foundation

public extension Array where Element:Encodable {

    /// Array where all elements have been transformed into a matching dictionary thanks to Json Serialization and Encodable protocol.
    /// - Note: If transformation is not possible, returned value is nil
    var dictionaries: [[String: Any]]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data)) as? [[String:Any]]
    }

    /// Pretty printed string output when an array can be converted into a valid JSON. Is equals to "not a valid JSON" string otherwise.
    /// - Note: This method is created for debug purpose, we don't advise you to use it in another context :)
    var jsonString: String {

        guard let data = try? JSONEncoder().encode(self),
            let dictionaries = (try? JSONSerialization.jsonObject(with: data)) as? [[String:Any]],
            let jsonData = try? JSONSerialization.data(withJSONObject: dictionaries, options: .prettyPrinted),
            let outputString = String(bytes: jsonData, encoding: String.Encoding.utf8) else {

                return "not a valid JSON"
        }

        return outputString
    }
}
