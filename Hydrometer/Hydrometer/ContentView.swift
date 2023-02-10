//
//  ContentView.swift
//  Created by Michael Simms on 8/18/22.
//

import SwiftUI

struct ContentView: View {
	@ObservedObject var appModel = HydrometerAppState.shared
	@State var logFileName: String = HydrometerAppState.shared.getLogFileName()

	let dateFormatter: DateFormatter = {
		let df = DateFormatter()
		df.dateStyle = .medium
		df.timeStyle = .short
		return df
	}()

	var body: some View {
		VStack(alignment: .center) {
			Text("Current Hydrometer Reading")
				.multilineTextAlignment(.center)
				.font(.title)
				.bold()
				.padding()
			if self.appModel.readingTime > 0 {
				Text("Time: \(self.dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(self.appModel.readingTime))))")
				Text("Temperature: \(String(format: "%.1f", self.appModel.readingTemp))")
					.padding()
				Text("Specific Gravity: \(String(format: "%.1f", self.appModel.readingGravity))")
					.padding()
			}
			else {
				Text("No data")
					.padding()
			}
			Text("Log File Name")
				.bold()
				.padding()
			TextField("", text: self.$logFileName, axis: .vertical)
				.onChange(of: self.logFileName) { value in
					self.appModel.setLogFileName(value: self.logFileName)
				}
				.multilineTextAlignment(.center)
				.padding()
		}
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
