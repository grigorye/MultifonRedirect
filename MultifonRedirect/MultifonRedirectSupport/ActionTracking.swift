//
//  ActionTracking.swift
//  MultifonRedirect
//
//  Created by Grigory Entin on 19.03.17.
//  Copyright © 2017 Grigory Entin. All rights reserved.
//

import Foundation

private let logger = ActionLogger()

public class Action {
	
	public enum Preflight {
		case cancelled(due: ActionCancellationTag)
		case succeeded
	}
	
	enum CompletionState {
		case failed
		case succeeded
	}
	
	public var preflight: Preflight? {
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
	
	public func failed(due error: Error) {
		completionState = .failed
		logger.failed(tag, error: error)
	}
	
	public func succeeded() {
		completionState = .succeeded
		logger.succeeded(tag)
	}
}

public typealias Preflight = Action.Preflight

public func would(_ tag: ActionTag) -> Action {
	return Action(with: tag)
}
