//
//  HydrometerApp.swift
//  Hydrometer
//
//  Created by Michael Simms on 8/18/22.
//

import SwiftUI
import CoreBluetooth

class HydrometerAppState : ObservableObject {
	
	static let shared = HydrometerAppState()

	private var logFileUrl: URL?
	@Published var readingTime: time_t = 0
	@Published var readingTemp: Float = 0
	@Published var readingGravity: Float = 0

	/// Constructor
	private init() {
	}

	/// Utility function for building the URL to the log file.
	func buildLogFileUrl() throws {

		// Build the URL for the application's directory.
		self.logFileUrl = FileManager.default.url(forUbiquityContainerIdentifier: nil)
		if self.logFileUrl == nil {
			throw LogFileException.runtimeError("iCloud storage is disabled.")
		}
		self.logFileUrl = logFileUrl?.appendingPathComponent("Documents")
		try FileManager.default.createDirectory(at: self.logFileUrl!, withIntermediateDirectories: true, attributes: nil)

		// Append the name of the log file to the path.
		self.logFileUrl = self.logFileUrl?.appendingPathComponent("log.csv", isDirectory: false)
	}

	func createLogFile() throws {
		
		// If the file doesn't exist then start it with the heading string.
		if !FileManager.default.fileExists(atPath: self.logFileUrl!.path) {

			// Write the heading string.
			let headingStr = "Time,Temperature,Gravity\n"
			try headingStr.write(to: self.logFileUrl!, atomically: true, encoding: String.Encoding.utf8)
		}
	}

	func storeReading() throws {
		let readingStr = String(format: "%u,%f,%f\n", self.readingTime, self.readingTemp, self.readingGravity)
		try readingStr.write(to: self.logFileUrl!, atomically: true, encoding: String.Encoding.utf8)
	}
	
	func convertTemperature(temperature: UInt16) -> Float {
		return Float(temperature)
	}
	
	func convertGravity(gravity: UInt16) -> Float {
		return Float(gravity) / 1000.0
	}
	
	/// Called when a manufacturer data read.
	func manufacturerDataRead(data: Data) -> Void {
		do {
			let measurement = try decodeHydrometerReading(data: data)
			self.readingTime = time(nil)
			self.readingTemp = convertTemperature(temperature: measurement.temperature)
			self.readingGravity = convertGravity(gravity: measurement.gravity)
			try storeReading()
		}
		catch {
		}
	}

	func startBluetoothScanning() -> BluetoothScanner {

		do {
			try buildLogFileUrl()
			try createLogFile()
		} catch {
			print(error.localizedDescription)
		}

		// Start scanning for the services that we are interested in.
		let scanner = BluetoothScanner()
		scanner.startScanningForManufactuerData(manufacturerDataRead: [manufacturerDataRead])
		return scanner
	}
}

@main
struct HydrometerApp: App {
	let state = HydrometerAppState.shared.startBluetoothScanning()

	var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
