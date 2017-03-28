//
//  RoutingController.swift
//  MultifonRedirect
//
//  Created by Grigory Entin on 11.03.17.
//  Copyright © 2017 Grigory Entin. All rights reserved.
//

import Foundation


enum RequestError: Error {
	case unused
	case urlSessionFailure(error: Error)
	case badHTTPStatus(response: HTTPURLResponse)
	case queryRoutingResponseParsingFailure(underlyingError: Error)
	case queryRoutingBackendRejected(resultCode: String, description: String?)
	case queryRoutingBackendBadAnswer
	case unknownRoutingInQueryResponse(String)
}

private func loginFromAccountNumber(_ accountNumber: String) -> String {
	return "\(accountNumber)@multifon.ru"
}

//
// MARK: Parsing and Generating
//

private func valueForChangeRequestFor(_ routing: Routing) -> String {
	return routing.rawValue
}

private func routingFrom(queryResponseData data: Data) throws -> Routing {
	let routing = try RoutingResponseParser(for: data).parse()
	return routing
}

private class RoutingResponseParser: NSObject {
	
	let data: Data
	
	init(for data: Data) {
		self.data = data
	}
	
	func parse() throws -> Routing {
		let responseParserDelegate = QueryRoutingResponseParserDelegate()
		let xmlParserDelegate = XMLParserDelegateForSimpleElementTracking() … {
			$0.delegate = responseParserDelegate
		}
		let xmlParser = XMLParser(data: data) … {
			$0.delegate = xmlParserDelegate
		}
		guard xmlParser.parse() else {
			throw RequestError.queryRoutingResponseParsingFailure(underlyingError: xmlParser.parserError!)
		}
		guard let parsedRouting = responseParserDelegate.responseRouting, responseParserDelegate.responseResultCode == "200" else {
			guard let resultCode = responseParserDelegate.responseResultCode else {
				throw RequestError.queryRoutingBackendBadAnswer
			}
			throw RequestError.queryRoutingBackendRejected(resultCode: resultCode, description: responseParserDelegate.responseResultDescription)
		}
		guard let routing = Routing(rawValue: parsedRouting) else {
			throw RequestError.unknownRoutingInQueryResponse(parsedRouting)
		}
		return routing
	}
	
}

private class QueryRoutingResponseParserDelegate: NSObject, SimpleElementTrackingXMLParserDelegate {
	
	var responseRouting: String?
	var responseResultCode: String?
	var responseResultDescription: String?
	
	func parser(_ parser: XMLParser, didEndElementWithPath elementPath: String, characters: String) {
		switch elementPath {
		case ".response.routing":
			responseRouting = characters
		case ".response.result.code":
			responseResultCode = characters
		case ".response.result.description":
			responseResultDescription = characters
		default: ()
		}
	}
}

class RoutingController {
	
	let accountNumber: String
	let password: String
	var lastRouting: Routing? = nil
	var lastUpdateDate: Date? = nil
	
	init(accountNumber: String, password: String) {
		self.accountNumber = accountNumber
		self.password = password
	}
	
	// MARK: -
	
	private func proceedWithQuery(data: Data?, response: URLResponse?, error: Error?, completionHandler: @escaping (Error?) -> ()) {
		if let error = error {
			completionHandler(RequestError.urlSessionFailure(error: error))
			return
		}
		let httpResponse = (response as! HTTPURLResponse)
		guard httpResponse.statusCode == 200 else {
			completionHandler(RequestError.badHTTPStatus(response: httpResponse))
			return
		}
		do {
			let routing = try routingFrom(queryResponseData: data!)
			lastRouting = routing
			lastUpdateDate = Date()
			completionHandler(nil)
		}
		catch {
			completionHandler(error)
		}
	}
	
	func query(completionHandler: @escaping (Error?) -> ()) -> (() -> ()) {
		let session = URLSession(configuration: .default)
		let login = loginFromAccountNumber(accountNumber)
		let url = URL(string: "https://sm.megafon.ru/sm/client/routing?login=\(login)&password=\(password)")!
		let task = session.dataTask(with: url) { (data, response, error) in
			self.proceedWithQuery(data: data, response: response, error: error, completionHandler: completionHandler)
		}
		task.resume()
		return {
			task.cancel()
		}
	}

	// MARK: -

	private func proceedWithSet(_ routing: Routing, data: Data?, response: URLResponse?, error: Error?, completionHandler: @escaping (RequestError?) -> ()) {
		if let error = error {
			completionHandler(.urlSessionFailure(error: error))
			return
		}
		let httpResponse = (response as! HTTPURLResponse)
		guard httpResponse.statusCode == 200 else {
			completionHandler(.badHTTPStatus(response: httpResponse))
			return
		}
		lastRouting = routing
		lastUpdateDate = Date()
		completionHandler(nil)
	}
	
	func set(_ routing: Routing, completionHandler: @escaping (RequestError?) -> ()) {
		let session = URLSession(configuration: .default)
		let login = loginFromAccountNumber(accountNumber)
		let url = URL(string: "https://sm.megafon.ru/sm/client/routing/set?login=\(login)&password=\(password)&routing=\(routing.rawValue)")!
		let task = session.dataTask(with: url) { (data, response, error) in
			self.proceedWithSet(routing, data: data, response: response, error: error, completionHandler: completionHandler)
		}
		task.resume()
	}

}
