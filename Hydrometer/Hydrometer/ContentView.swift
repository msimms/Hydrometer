//
//  ContentView.swift
//  Created by Michael Simms on 8/18/22.
//

import SwiftUI

struct ContentView: View {
	@ObservedObject var appModel = HydrometerAppState.shared

	var body: some View {
		Text("Current Reading")
			.bold()
			.padding()
		Text("Temperature \(String(format: "%.1f", self.appModel.readingTemp))")
			.padding()
		Text("Temperature \(String(format: "%.1f", self.appModel.readingGravity))")
			.padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
