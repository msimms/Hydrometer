//
//  ContentView.swift
//  Created by Michael Simms on 8/18/22.
//

import SwiftUI

struct ContentView: View {
	@ObservedObject var appModel = HydrometerAppState.shared
	@State var logFileName: String = HydrometerAppState.shared.hydrometerState.getLogFileName()

	let dateFormatter: DateFormatter = {
		let df = DateFormatter()
		df.dateStyle = .medium
		df.timeStyle = .short
		return df
	}()

	var body: some View {
		TabView {
			VStack(alignment: .center) {
				Text("Current Hydrometer Reading")
					.multilineTextAlignment(.center)
					.font(.title)
					.bold()
					.padding()
				if self.appModel.hydrometerState.lastUpdatedTime > 0 {
					Text("Time: \(self.dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(self.appModel.hydrometerState.lastUpdatedTime))))")
					Text("Temperature: \(String(format: "%.1f", self.appModel.hydrometerState.currentTemp))")
						.padding()
					Text("Specific Gravity: \(String(format: "%.3f", self.appModel.hydrometerState.currentGravity))")
						.padding()
					Text("ABV: \(String(format: "%.3f %%", self.appModel.hydrometerState.currentAbv))")
						.padding()
					
					VStack() {
						if self.appModel.hydrometerState.sgReadings.count > 1 {
							LineGraphView(points: self.appModel.hydrometerState.sgReadings, color: self.appModel.hydrometerState.hydrometerColor)
							Text("SG vs. Elapsed Time")
						}
					}
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
