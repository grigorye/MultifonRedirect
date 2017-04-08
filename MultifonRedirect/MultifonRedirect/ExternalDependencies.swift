//
//  ExternalDependencies.swift
//  MultifonRedirect
//
//  Created by Grigory Entin on 25.02.17.
//  Copyright © 2017 Grigory Entin. All rights reserved.
//

import Foundation

var _false = false
var _true = true

extension NSObject {
	
	func retainedIn(_ object: NSObject) -> Self {
		let assoc = Unmanaged.passUnretained(self).toOpaque()
		objc_setAssociatedObject(object, assoc, self, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
		return self
	}
	
}

// https://support.apple.com/kb/TA45403?locale=en_US&viewlocale=en_US

typealias LogCStringF = @convention(c) (_ message: UnsafeMutableRawPointer, _ length: CUnsignedInt, _ banner: CBool) -> Void

#if GE_NSLOG_REDIRECTION_ENABLED
@available(iOS 9.0, macOS 10.12, watchOS 3.0, tvOS 10.0, *)
@_silgen_name("_NSSetLogCStringFunction") private func NSSetLogCStringFunction(_ f: LogCStringF)

let logCString: LogCStringF = { messageBytes, length, banner in
	let message = String(bytesNoCopy: messageBytes, length: Int(length), encoding: .utf8, freeWhenDone: false)!
	print(message)
}

public let nslogRedirectorInitializer: Void = {
	NSSetLogCStringFunction(logCString)
}()
#else
public let nslogRedirectorInitializer: Void = ()
#endif
