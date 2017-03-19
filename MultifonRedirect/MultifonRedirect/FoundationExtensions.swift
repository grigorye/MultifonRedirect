//
//  Extensions.swift
//  MultifonRedirect
//
//  Created by Grigory Entin on 26.02.17.
//  Copyright © 2017 Grigory Entin. All rights reserved.
//

import Foundation

protocol SimpleElementTrackingXMLParserDelegate {

	func parser(_ parser: XMLParser, didEndElementWithPath elementPath: String, characters: String)

}

class XMLParserDelegateForSimpleElementTracking: NSObject, XMLParserDelegate {

	var delegate: SimpleElementTrackingXMLParserDelegate?
	
	var currentElementPath = ""
	var currentElementCharacters = ""
	var outerElementsCharacters: [String] = []
	
	func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
		currentElementPath += ".\(elementName)"
		outerElementsCharacters += [currentElementCharacters]
		currentElementCharacters = ""
	}
	
	func parser(_ parser: XMLParser, foundCharacters string: String) {
		currentElementCharacters += string
	}
	
	func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
		//
		delegate!.parser(parser, didEndElementWithPath: currentElementPath, characters: currentElementCharacters)
		let suffix = ".\(elementName)"
		assert(currentElementPath.hasSuffix(suffix))
		currentElementPath = currentElementPath.substring(to: currentElementPath.index(currentElementPath.endIndex, offsetBy: -suffix.distance(from: suffix.startIndex, to: suffix.endIndex)))
		currentElementCharacters = outerElementsCharacters.popLast()!
	}

}
