//
//  SystemInfo.swift
//  BuildTimeLogger
//
//  Created by Marcin Religa on 20/03/2017.
//  Copyright © 2017 Marcin Religa. All rights reserved.
//

import Foundation

struct DevToolsInfo {
    let version: String
}

struct SystemInfo {
	let hardware: HardwareInfo
	let devTools: DevToolsInfo
}
