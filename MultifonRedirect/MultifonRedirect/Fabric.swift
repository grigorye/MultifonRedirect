//
//  Fabric.swift
//  MultifonRedirect
//
//  Created by Grigory Entin on 04.03.17.
//  Copyright © 2017 Grigory Entin. All rights reserved.
//

import Foundation
import Fabric
import Crashlytics

let fabricInitializer: Void = {
	Fabric.sharedSDK().debug = true
	Fabric.with([Crashlytics()])
}()
