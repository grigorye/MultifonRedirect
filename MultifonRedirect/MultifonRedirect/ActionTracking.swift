//
//  ActionTracking.swift
//  MultifonRedirect
//
//  Created by Grigory Entin on 19.03.17.
//  Copyright © 2017 Grigory Entin. All rights reserved.
//

import Foundation

private let logger = ActionLogger()

class Action {
	
	enum Preflight {
		case cancelled(due: ActionCancellationTag)
		case succeeded
	}
	
	enum CompletionState {
		case failed
		case succeeded
	}
	
	var preflight: Preflight? {
		didSet {
			if case .cancelled(let due)? = preflight {
				logger.cancelled(tag, due: due)
			}
		}
	}
	var tag: ActionTag
	
	var completionState: CompletionState?
	
	deinit {
		assert({
			if let _ = completionState {
				return true
			} else {
				switch preflight {
				case .cancelled?: return true
				default:
					return false
				}
			}
		}())
	}
	
	init(with tag: ActionTag) {
		self.tag = tag
		logger.started(tag)
	}
	
	func failed(due error: Error) {
		completionState = .failed
		logger.failed(tag, error: error)
	}
	
	func succeeded() {
		completionState = .succeeded
		logger.succeeded(tag)
	}
}

typealias Preflight = Action.Preflight

func would(_ tag: ActionTag) -> Action {
	return Action(with: tag)
}
