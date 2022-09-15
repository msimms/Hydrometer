//
//  HydrometerApp.swift
//  Hydrometer
//
//  Created by Michael Simms on 8/18/22.
//

import SwiftUI
import CoreBluetooth

class AppState : ObservableObject {
	
	static let shared = AppState()
	@Published var currentTemp: Float = 0
	@Published var currentGravity: Float = 0

	/// Utility function for building the URL to the log file.
	func buildLogFileUrl() throws -> URL? {
		
		var logFileUrl: URL?
		
		// Build the URL for the application's directory.
		logFileUrl = FileManager.default.url(forUbiquityContainerIdentifier: nil)
		if logFileUrl == nil {
			throw LogFileException.runtimeError("iCloud storage is disabled.")
		}
		logFileUrl = logFileUrl?.appendingPathComponent("Documents")
		try FileManager.default.createDirectory(at: logFileUrl!, withIntermediateDirectories: true, attributes: nil)

		// Append the name of the log file to the path.
		return logFileUrl?.appendingPathComponent("log.csv", isDirectory: false)
	}

	func createLogFile() {
		do {
			let logFileUrl = try buildLogFileUrl()

			if !FileManager.default.fileExists(atPath: logFileUrl!.path) {

				// Write the heading string.
				let headingStr = "Time\tTemperature\nGravity"
				try headingStr.write(to: logFileUrl!, atomically: true, encoding: String.Encoding.utf8)
			}
		} catch {
			print(error.localizedDescription)
		}
	}

	func storeReading() {
	}
	
	func convertTemperature(temperature: UInt16) -> Float {
		0.0
	}
	
	func convertGravity(gravity: UInt16) -> Float {
		0.0
	}
	
	/// Called when a manufacturer data read.
	func manufacturerDataRead(data: Data) -> Void {
		do {
			let measurement = try decodeHydrometerReading(data: data)
		}
		catch {
		}
	}

	func startBluetoothScanning() -> BluetoothScanner {

		createLogFile()

		// Start scanning for the services that we are interested in.
		let scanner = BluetoothScanner()
		scanner.startScanningForManufactuerData(manufacturerDataRead: [manufacturerDataRead])
		return scanner
	}
}

@main
struct HydrometerApp: App {
	let state = AppState.shared.startBluetoothScanning()

	var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
