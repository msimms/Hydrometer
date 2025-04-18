//
//  ContentView.swift
//  Created by Michael Simms on 8/18/22.
//

import SwiftUI

struct HydrometerView: View {
	enum Field: Hashable {
		case logFileName
	}

	@State var hydrometerName: String
	@State var logFileName: String = ""
	@FocusState private var focusedField: Field?

	let dateFormatter: DateFormatter = {
		let df = DateFormatter()
		df.dateStyle = .medium
		df.timeStyle = .short
		return df
	}()

	func sgFormatter(num: Double) -> String {
		return String(format: "%0.3f", num)
	}

	func formatDate(ts: Double) -> String {
		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .short
		dateFormatter.timeStyle = .none
		
		let formattedDate = dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(ts)))
		return formattedDate
	}

	var body: some View {
		VStack(alignment: .center) {
			Text("Hydrometer Readings")
				.multilineTextAlignment(.center)
				.font(.title)
				.bold()
				.padding()
			let hydrometerState = HydrometerAppState.shared.selectedHydrometerByName(name: self.hydrometerName).start()
			if hydrometerState.lastUpdatedTime > 0 {
				Text("\(self.dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(hydrometerState.lastUpdatedTime))))")
					.bold()
				Text("Temperature: \(String(format: "%.1f F", hydrometerState.currentTemp))")
				Text("Original Gravity: \(String(format: "%.3f", hydrometerState.sgReadings.first?.1 ?? "n/a"))")
				Text("Specific Gravity: \(String(format: "%.3f", hydrometerState.currentGravity))")
				Text("ABV: \(String(format: "%.3f %%", hydrometerState.currentAbv))")
				VStack() {
					if hydrometerState.sgReadings.count > 1 {
						LineGraphView(points: hydrometerState.sgReadings, color: hydrometerState.hydrometerColor, xFormatter: self.formatDate, yFormatter: self.sgFormatter)
							.padding()
						Text("SG vs. Time")
							.bold()
					}
					else {
						Text("Not enough data to plot")
					}
				}
				.padding()
			}
			else {
				Text("No data")
					.bold()
					.padding()
			}
			VStack() {
				Text("Log File Name")
					.bold()
				TextField("", text: self.$logFileName, axis: .vertical)
					.onChange(of: self.logFileName) { value in
						hydrometerState.setLogFileName(value: self.logFileName)
					}
					.onAppear() {
						self.logFileName = hydrometerState.getLogFileName()
					}
					.focused(self.$focusedField, equals: .logFileName)
					.multilineTextAlignment(.center)
			}
			.padding()
			Spacer()
		}
		.toolbar {
			ToolbarItem(placement: .keyboard) {
				Button("Done") {
					self.focusedField = nil
				}
			}
		}
    }
}

struct ContentView: View {
	@State private var activeTab: Int = 0

	var body: some View {
		TabView(selection: self.$activeTab) {
			ForEach(Array(zip(HYDROMETER_NAMES, HYDROMETER_COLORS)), id: \.0) { item in
				HydrometerView(hydrometerName: item.0)
					.tabItem {
						Label(item.0, systemImage: "testtube.2")
					}
			}
		}
		.onChange(of: self.activeTab, perform: { index in
		})
	}
}
