//
//  _VExpFriendly.swift
//  RReminders
//
//  Created by Francis Grolemund on 5/1/25.
//

import SwiftUI

// this experiment is to try out an idea for establishing friend-like
// relationships between co-located source files and classes since
// Swift's access control doesn't support that within the same common
// module.  This is not split into two files here to not pollute the
// main app's namespace, so some extrapolation is required.

fileprivate struct _VExpFriendly: View {
	@State private var master: Master = .init()
    var body: some View {
		VStack(spacing: 20) {
			MasterView(master: master)
			SlaveView(slave: master.addDependent())
		}
    }
}

fileprivate struct MasterView : View {
	let master: Master
	var body: some View {
		VStack {
			Text("Primary")
				.font(.title2)
				
			Text("Value = \(master.secret)")
		}
	}
}

fileprivate struct SlaveView : View {
	let slave: Slave
	
	var body: some View {
		Button("Increment Secret") {
			slave.incrementSecret()
		}
	}
}

#Preview {
    _VExpFriendly()
}

// - the 'internal' behavior to a group of files can be passed in these
//   types of objects with the idea that the target object is a weak
//   reference inside, reducing the likelihood of accidental circular references
//   too.
fileprivate protocol MasterFriendly : AnyObject {
	func incrementSecret()
}

@Observable
fileprivate class Master {
	init() {
		_secret = 0
	}
	
	var secret: Int { _secret }

	func addDependent() -> Slave {
		let coord = MasterCoordinator(master: self)
		return Slave(mf: coord)
	}
	
	private var _secret: Int
}

fileprivate extension Master {
	private class MasterCoordinator : MasterFriendly {
		weak var master: Master?
		
		init(master: Master? = nil) {
			self.master = master
		}
		
		func incrementSecret() {
			master?._secret += 1
		}
	}
}

fileprivate class Slave {
	let mf: MasterFriendly
	
	init(mf: MasterFriendly) {
		self.mf = mf
	}
	
	func incrementSecret() {
		mf.incrementSecret()
	}
}
