//
//  ContentView.swift
//  Hydrometer
//
//  Created by Michael Simms on 8/18/22.
//

import SwiftUI

struct ContentView: View {
	@ObservedObject var appModel = HydrometerAppState.shared

	var body: some View {
		Text("Temperature: \(self.appModel.readingTemp)")
			.padding()
		Text("Gravity: \(self.appModel.readingGravity)")
			.padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
