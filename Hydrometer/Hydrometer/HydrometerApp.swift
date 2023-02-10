//
//  HydrometerApp.swift
//  Created by Michael Simms on 8/18/22.
//

import SwiftUI
import CoreLocation

let PREF_NAME_LOG_FILE_NAME = "Log File Name"
let DEFAULT_LOG_FILE_NAME = "log.csv"

class HydrometerAppState : ObservableObject {
	
	static let shared = HydrometerAppState()

	private var beaconScanner: LocationSensor = LocationSensor()
	private var logFileUrl: URL?
	@Published var readingTime: time_t = 0
	@Published var readingTemp: Float = 0
	@Published var readingGravity: Float = 0

	/// Constructor
	private init() {
	}

	func setLogFileName(value: String) {
		let mydefaults: UserDefaults = UserDefaults.standard
		mydefaults.set(value, forKey: PREF_NAME_LOG_FILE_NAME)
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

	func createLogFile() throws {
		
		// If the file doesn't exist then start it with the heading string.
		if !FileManager.default.fileExists(atPath: self.logFileUrl!.path) {

			// Write the heading string.
			let headingStr = "Time,Temperature,Gravity\n"
			try headingStr.write(to: self.logFileUrl!, atomically: true, encoding: String.Encoding.utf8)
		}
	}

	func storeReading() throws {
		if let fileUpdater = try? FileHandle(forUpdating: self.logFileUrl!) {
			
			// Format the time the reading was made into something human readable.
			let formatter = DateFormatter()
			formatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
			let timestamp = formatter.string(from: Date(timeIntervalSince1970: Double(self.readingTime)))
			
			// Build the CSV row string.
			let strToWrite = String(format: "%@,%.1f,%.1f\n", timestamp, self.readingTemp, self.readingGravity)
			
			// Seek to the end of the file and write.
			fileUpdater.seekToEndOfFile()
			fileUpdater.write(strToWrite.data(using: .utf8)!)
			fileUpdater.closeFile()
		}
	}

	func hydrometerBeaconReceived(beacon: CLBeacon) -> Void {
		do {
			let now = time(nil)
			
			// Only update the document every ten minutes.
			if now > self.readingTime + 600 {
				self.readingTime = now
				self.readingTemp = Float(truncating: beacon.major)
				self.readingGravity = Float(truncating: beacon.minor)
				
				try storeReading()
			}
		}
		catch {
		}
	}

	func start() -> HydrometerAppState {
		do {
			try buildLogFileUrl()
			try createLogFile()
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
