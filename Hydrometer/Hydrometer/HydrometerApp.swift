//
//  HydrometerApp.swift
//  Created by Michael Simms on 8/18/22.
//

import SwiftUI
import CoreLocation
import TabularData

let PREF_NAME_LOG_FILE_NAME = "Log File Name"
let DEFAULT_LOG_FILE_NAME = "log.csv"

class HydrometerAppState : ObservableObject {
	
	static let shared = HydrometerAppState()

	private var beaconScanner: LocationSensor = LocationSensor()
	private var logFileUrl: URL?
	@Published var currentTime: time_t = 0
	@Published var currentTemp: Double = 0.0
	@Published var currentGravity: Double = 0.0
	@Published var currentAbv: Double = 0.0
	@Published var sgReadings: Array<Double> = []

	/// Constructor
	private init() {
	}

	func setLogFileName(value: String) {
		let mydefaults: UserDefaults = UserDefaults.standard
		mydefaults.set(value, forKey: PREF_NAME_LOG_FILE_NAME)

		// Update the cached log file URL.
		let _ = self.start()
	}
	
	func getLogFileName() -> String {
		let mydefaults: UserDefaults = UserDefaults.standard
		let logFileName = mydefaults.string(forKey: PREF_NAME_LOG_FILE_NAME)

		if logFileName == nil {
			return DEFAULT_LOG_FILE_NAME
		}
		return logFileName!
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
		self.logFileUrl = self.logFileUrl?.appendingPathComponent(self.getLogFileName(), isDirectory: false)
	}

	/// Creates the log file if it does not already exist. Adds the column headers when creating.
	func createLogFile() throws {
		
		// If the file doesn't exist then start it with the heading string.
		if !FileManager.default.fileExists(atPath: self.logFileUrl!.path) {

			// Write the heading string.
			let headingStr = "Time,Temperature,Gravity\n"
			try headingStr.write(to: self.logFileUrl!, atomically: true, encoding: String.Encoding.utf8)
		}
	}

	/// Restore history from the CSV file.
	func readLogFile() throws -> Array<Double> {
		let result = try DataFrame(contentsOfCSVFile: self.logFileUrl!)
		let gravityList = result.columns[2].map({ ($0 as? Double)! })
		return gravityList
	}

	/// Adds another row to the log file.
	func updateLogFile() throws {
		if let fileUpdater = try? FileHandle(forUpdating: self.logFileUrl!) {
			
			// Format the time the reading was made into something human readable.
			let formatter = DateFormatter()
			formatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
			let timestamp = formatter.string(from: Date(timeIntervalSince1970: Double(self.currentTime)))
			
			// Build the CSV row string.
			let strToWrite = String(format: "%@,%.1f,%.3f\n", timestamp, self.currentTemp, self.currentGravity)
			
			// Seek to the end of the file and write.
			fileUpdater.seekToEndOfFile()
			fileUpdater.write(strToWrite.data(using: .utf8)!)
			fileUpdater.closeFile()
		}
	}
	
	func calculateAbv(originalSg: Double, currentSg: Double) -> Double {
		let abv = (76.08 * (originalSg - currentSg) / (1.775 - originalSg)) * (currentSg / 0.794)
		return abv
	}

	func hydrometerBeaconReceived(beacon: CLBeacon) -> Void {
		do {
			let now = time(nil)
			
			// Only update every ten minutes.
			if now > self.currentTime + 600 {
				self.currentTime = now
				self.currentTemp = Double(truncating: beacon.major)
				self.currentGravity = Double(truncating: beacon.minor) / 1000.0
				self.sgReadings.append(self.currentGravity)
				self.currentAbv = self.calculateAbv(originalSg: self.sgReadings[0], currentSg: self.currentGravity)

				try updateLogFile()
			}
		}
		catch {
		}
	}

	func start() -> HydrometerAppState {
		do {
			try buildLogFileUrl()
			try createLogFile()
			self.sgReadings = try readLogFile()
		} catch {
			print(error.localizedDescription)
		}
		return self
	}
}

@main
struct HydrometerApp: App {
	let state = HydrometerAppState.shared.start()

	var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
