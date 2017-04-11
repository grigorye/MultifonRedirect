//
//  RequestErrorPresentation.swift
//  MultifonRedirect
//
//  Created by Grigory Entin on 25.02.17.
//  Copyright © 2017 Grigory Entin. All rights reserved.
//

import Foundation
import MultifonRedirectSupport

extension RequestError {

	typealias L = RequestErrorLocalized

	static func setUserInfoValueProvider() {
		let errorDomain = (self.unused as NSError).domain
		NSError.setUserInfoValueProvider(forDomain: (errorDomain)) { error, key in
			switch error {
			case RequestError.urlSessionFailure(let underlyingError):
				return (underlyingError as NSError).userInfo[key]
			case RequestError.badHTTPStatus(_):
				if key == NSLocalizedDescriptionKey {
					return L.unexpectedServerResponse
				}
				return nil
			case RequestError.queryRoutingBackendRejected(let resultCode, _):
				if key == NSLocalizedDescriptionKey {
					switch resultCode {
					case "101": return L.wrongPassword
					case "102": return L.routeChangeIsNotAllowed
					case "404": return L.accountNotFound
					default: return nil
					}
				}
				return nil
			default:
				return nil
			}
		}
	}

}
