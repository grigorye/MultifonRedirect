//
//  Data.swift
//  MultifonRedirect
//
//  Created by Grigory Entin on 25.02.17.
//  Copyright © 2017 Grigory Entin. All rights reserved.
//

import Foundation

enum Routing: String {
	case phoneOnly = "0"
	case multifonOnly = "1"
	case phoneAndMultifon = "2"
}

enum RequestError: Error {
	case unused
	case urlSessionFailure(error: Error)
	case badHTTPStatus(response: HTTPURLResponse)
	case queryRoutingResponseParsingFailure(underlyingError: Error)
	case queryRoutingBackendRejected(resultCode: String, description: String?)
	case queryRoutingBackendBadAnswer
	case unknownRoutingInQueryResponse(String)
}

func loginFromAccountNumber(_ accountNumber: String) -> String {
	return "\(accountNumber)@multifon.ru"
}

//
// MARK: Parsing and Generating
//

func valueForChangeRequestFor(_ routing: Routing) -> String {
	return routing.rawValue
}

func routingFrom(queryResponseData data: Data) throws -> Routing {
	let routing = try RoutingResponseParser(for: data).parse()
	return routing
}

class RoutingResponseParser: NSObject {

	let data: Data
	
	init(for data: Data) {
		self.data = data
	}
	
	func parse() throws -> Routing {
		let responseParserDelegate = QueryRoutingResponseParserDelegate()
		let xmlParserDelegate: XMLParserDelegate = {
			let $ = XMLParserDelegateForSimpleElementTracking()
			$.delegate = responseParserDelegate
			return $
		}()
		let xmlParser: XMLParser = {
			let $ = XMLParser(data: data)
			$.delegate = xmlParserDelegate
			return $
		}()
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

class QueryRoutingResponseParserDelegate: NSObject, SimpleElementTrackingXMLParserDelegate {

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

//
// MARK: Querying and Changing
//

func query(accountNumber: String, password: String, completionHandler: @escaping (Error?, Routing?) -> ()) {
	let session = URLSession(configuration: .default)
	let login = loginFromAccountNumber(accountNumber)
	let url = URL(string: "https://sm.megafon.ru/sm/client/routing?login=\(login)&password=\(password)")!
	let task = session.dataTask(with: $(url), completionHandler: { (data, response, error) in
		if let error = error {
			completionHandler(RequestError.urlSessionFailure(error: $(error)), nil)
			return
		}
		let httpResponse = (response as! HTTPURLResponse)
		guard httpResponse.statusCode == 200 else {
			completionHandler(RequestError.badHTTPStatus(response: $(httpResponse)), nil)
			return
		}
		do {
			let routing = try routingFrom(queryResponseData: data!)
			completionHandler(nil, $(routing))
		}
		catch {
			completionHandler(error, nil)
		}
	})
	task.resume()
}

func change(accountNumber: String, password: String, routing: Routing, completionHandler: @escaping (RequestError?) -> ()) {
	let session = URLSession(configuration: .default)
	let login = loginFromAccountNumber(accountNumber)
	let url = URL(string: "https://sm.megafon.ru/sm/client/routing/set?login=\(login)&password=\(password)&routing=\(routing.rawValue)")!
	let task = session.dataTask(with: $(url), completionHandler: { (data, response, error) in
		if let error = error {
			completionHandler(.urlSessionFailure(error: $(error)))
			return
		}
		let httpResponse = (response as! HTTPURLResponse)
		guard httpResponse.statusCode == 200 else {
			completionHandler(.badHTTPStatus(response: $(httpResponse)))
			return
		}
		completionHandler(nil)
	})
	task.resume()
}
