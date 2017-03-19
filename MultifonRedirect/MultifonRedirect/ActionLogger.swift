//
//  ActionLogger.swift
//  MultifonRedirect
//
//  Created by Grigory Entin on 19.03.17.
//  Copyright © 2017 Grigory Entin. All rights reserved.
//

import Foundation


public typealias EventLogger = (_ name: String, _ attributes: [String : Any]?) -> Void

private func logEventToConsole(withName name: String, attributes: [String : Any]? = nil) {
	let suffix: String = {
		guard let attributes = attributes else {
			return ""
		}
		return " Attributes: \(attributes)."
	}()
	print("Event: \(name)." + suffix)
}

public var eventLoggers: [EventLogger] = [
	logEventToConsole
]

private func logEventToLoggers(withName name: String, attributes: [String : Any]? = nil) {
	for logEvent in eventLoggers {
		logEvent(name, attributes)
	}
}

private func childrenMirror(_ children: Mirror.Children) -> [String : Any] {
	var result = [String : Any]()
	for child in children {
		if let key = child.label {
			result[key] = mirrored(child.value)
		}
	}
	return result
}

private func mirrored<T>(_ value: T) -> Any {
	let children = Mirror(reflecting: value).children
	if 0 < children.count {
		return childrenMirror(children)
	} else {
		return "\(value)"
	}
}

struct ActionLogger {
	
	private func logEvent(prefix: String, _ actionTag: ActionTag, attributes eventAttributes: [String : Any]? = nil) {
		let (actionName, actionAttributes): (String, [String : Any]?) = {
			let mirror = Mirror(reflecting: actionTag)
			let children = mirror.children
			if let compoundChild = children.first {
				return (compoundChild.label!, Optional(mirrored(compoundChild.value) as! [String : Any]))
			} else {
				return ("\(actionTag)", nil)
			}
		}()
		logEventToLoggers(withName: "\(prefix).\(actionName)", attributes: {
			guard nil != actionAttributes || nil != eventAttributes else {
				return nil
			}
			var attributes = [String : Any]()
			if let actionAttributes = actionAttributes {
				attributes["action"] = actionAttributes
			}
			if let eventAttributes = eventAttributes {
				attributes["event"] = eventAttributes
			}
			return attributes
		}())
	}
	
	func started(_ actionTag: ActionTag) {
		logEvent(prefix: "Will", actionTag)
	}
	
	func cancelled(_ actionTag: ActionTag, due: ActionCancellationTag) {
		logEvent(prefix: "Cancelled", actionTag, attributes: ["due": mirrored(due)])
	}
	
	func failed(_ actionTag: ActionTag, error: Error) {
		logEvent(prefix: "Failed", actionTag, attributes: ["error": mirrored(error)])
	}
	
	func succeeded(_ actionTag: ActionTag) {
		logEvent(prefix: "Succeeded", actionTag)
	}
	
}
