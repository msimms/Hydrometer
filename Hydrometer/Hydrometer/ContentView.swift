//
//  ContentView.swift
//  Created by Michael Simms on 8/18/22.
//

import SwiftUI

struct HydrometerView: View {
	var hydrometerName: String
	@ObservedObject var appModel: HydrometerAppState = HydrometerAppState.shared
	@State var logFileName: String = ""

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
			let hydrometerState = self.appModel.selectedHydrometerByName(name: hydrometerName).start()
			if hydrometerState.lastUpdatedTime > 0 {
				Text("Time: \(self.dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(hydrometerState.lastUpdatedTime))))")
				Text("Temperature: \(String(format: "%.1f", hydrometerState.currentTemp))")
					.padding()
				Text("Specific Gravity: \(String(format: "%.3f", hydrometerState.currentGravity))")
					.padding()
				Text("ABV: \(String(format: "%.3f %%", hydrometerState.currentAbv))")
					.padding()
				VStack() {
					if hydrometerState.sgReadings.count > 1 {
						LineGraphView(points: hydrometerState.sgReadings, color: hydrometerState.hydrometerColor)
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
					hydrometerState.setLogFileName(value: self.logFileName)
				}
				.onAppear() {
					self.logFileName = hydrometerState.getLogFileName()
				}
				.multilineTextAlignment(.center)
			Spacer()
		}
    }
}

struct ContentView: View {
	var body: some View {
		TabView {
			ForEach(Array(zip(HYDROMETER_NAMES, HYDROMETER_COLORS)), id: \.0) { item in
				HydrometerView(hydrometerName: item.0)
					.tabItem {
						Label(item.0, systemImage: "testtube.2")
					}
			}
		}
	}
}
