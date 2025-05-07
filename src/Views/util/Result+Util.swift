//
//  Result+Util.swift
//  RReminders
//
//  Created by Francis Grolemund on 4/29/25.
//

import Foundation

extension Result where Success == Bool, Failure == Error {
	var isOk: Bool {
		if case .success(let val) = self, val {
			return true
		}
		return false
	}
	
	var asError: Error? {
		if case .failure(let err) = self {
			return err
		}
		return nil
	}
}
