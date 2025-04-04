//
//  VTimePicker.swift
//  RReminders
//
//  Created by Francis Grolemund on 3/19/25.
//

import Foundation
import SwiftUI
import UIKit

struct VTimePicker: View {
	@Binding var time: Date

    var body: some View {
		VTimePickerController(time: $time)
			.frame(minHeight: 190)
    }
}


#Preview {
	@Previewable @State var time: Date = .now
	Form {
		VTimePicker(time: $time)
	}
	.onChange(of: time) { oldValue, newValue in
		print("Date/time changed to \(DateFormatter.localizedString(from: newValue, dateStyle: .none, timeStyle: .short))")
	}
}


fileprivate struct VTimePickerController : UIViewControllerRepresentable {
	@Binding var time: Date

	func makeUIViewController(context: Context) -> UITimePickerViewController {
		let ret = UITimePickerViewController()
		ret.datePicker.addTarget(context.coordinator, action: #selector(Coordinator.didChangeDate(sender:)), for: .valueChanged)
		return ret
	}
	
	func updateUIViewController(_ vc: UITimePickerViewController, context: Context) {
		vc.datePicker.date = time
	}
	
	// - when you need a reference type to serve as a delegate linking
	//   back to the View, a Coordinator can act as that bridge
	class Coordinator: NSObject {
		var parent: VTimePickerController
		
		init(parent: VTimePickerController) {
			self.parent = parent
		}
		
		@IBAction func didChangeDate(sender: UIDatePicker) {
			parent.time = sender.date
		}
	}
	
	func makeCoordinator() -> Coordinator {
		return Coordinator(parent: self)
	}
}

fileprivate class UITimePickerViewController : UIViewController {
	var datePicker: UIDatePicker { self.view as! UIDatePicker }

	override func loadView() {
		self.view = UIDatePicker()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		datePicker.preferredDatePickerStyle = .wheels
		datePicker.datePickerMode = .time
		datePicker.minuteInterval = 5
	}
}
