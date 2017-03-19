//
//  Fabric.swift
//  MultifonRedirect
//
//  Created by Grigory Entin on 04.03.17.
//  Copyright © 2017 Grigory Entin. All rights reserved.
//

import Foundation
import Fabric
import Answers

private func logEventToAnswers(name: String, attributes: [String : Any]? = nil) {
	Answers.logCustomEvent(withName: name, customAttributes: attributes)
}

let fabricInitializer: Void = {
	Fabric.sharedSDK().debug = true
	Fabric.with([Answers()])
	eventLoggers += [logEventToAnswers]
}()
