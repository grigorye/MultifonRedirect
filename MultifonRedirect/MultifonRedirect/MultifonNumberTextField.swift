//
//  MultifonNumberTextField.swift
//  MultifonRedirect
//
//  Created by Grigory Entin on 28.02.17.
//  Copyright © 2017 Grigory Entin. All rights reserved.
//

import PhoneNumberKit

class MultifonNumberTextField: PhoneNumberTextField {
	
	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.defaultRegion = defaultRegion
	}
	
}
