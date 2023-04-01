//
//  HydrometerState.swift
//  Created by Michael Simms on 4/1/23.
//

import SwiftUI
import Foundation
import CoreLocation
import TabularData

class HydrometerState : ObservableObject {
	@Published var logFileUrl: URL?
	@Published var lastUpdatedTime: UInt64 = 0
	@Published var currentTemp: Double = 0.0
	@Published var currentGravity: Double = 0.0
	@Published var currentAbv: Double = 0.0
	@Published var sgReadings: Array<(UInt64, Double)> = []
	@Published var hydrometerId: UUID
	@Published var hydrometerName: String
	@Published var hydrometerColor: Color

	/// Constructor
	init(id: UUID, name: String, color: Color) {
		self.hydrometerId = id
		self.hydrometerName = name
		self.hydrometerColor = color
	}
	
	func getLogFileName() -> String {
		let mydefaults: UserDefaults = UserDefaults.standard
		let logFileName = mydefaults.string(forKey: PREF_NAME_LOG_FILE_NAME)
		
		if logFileName == nil {
			return DEFAULT_LOG_FILE_NAME
		}
		return logFileName!
	}

	func setLogFileName(value: String) {
		let mydefaults: UserDefaults = UserDefaults.standard
		mydefaults.set(value, forKey: PREF_NAME_LOG_FILE_NAME)
		
		// Update the cached log file URL.
		let _ = self.start()
	}
	
	/// Utility function for building the URL to the log file.
	func buildLogFileUrl() throws {
		
		// Build the URL for the application's directory.
		self.logFileUrl = FileManager.default.url(forUbiquityContainerIdentifier: nil)
		if self.logFileUrl == nil {
			throw LogFileException.runtimeError("iCloud storage is disabled.")
		}
		self.logFileUrl = self.logFileUrl?.appendingPathComponent("Documents")
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
	func readLogFile() throws {
		let result = try DataFrame(contentsOfCSVFile: self.logFileUrl!)
		if result.columns.count >= 3 {
			let dateFormatter = DateFormatter()
			dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
			
			let timestampReadings = result.columns[0].map({ UInt64(dateFormatter.date(from: $0 as? String ?? "")?.timeIntervalSince1970 ?? 0) })
			let gravityReadings = result.columns[2].map({ ($0 as? Double) ?? 0.0 })
			
			self.sgReadings = Array(zip(timestampReadings, gravityReadings))
			self.lastUpdatedTime = timestampReadings.last!
			self.currentTemp = (result.columns[1].last as? Double) ?? 0.0
			self.currentGravity = gravityReadings.last!
			self.currentAbv = self.calculateAbv(originalSg: self.sgReadings[0].1, currentSg: self.currentGravity)
		}
	}
	
	/// Adds another row to the log file.
	func updateLogFile() throws {
		if let fileUpdater = try? FileHandle(forUpdating: self.logFileUrl!) {
			
			// Format the time the reading was made into something human readable.
			let formatter = DateFormatter()
			formatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
			let timestamp = formatter.string(from: Date(timeIntervalSince1970: Double(self.lastUpdatedTime)))
			
			// Build the CSV row string.
			let strToWrite = String(format: "%@,%.1f,%.3f\n", timestamp, self.lastUpdatedTime, self.currentGravity)
			
			// Seek to the end of the file and write.
			fileUpdater.seekToEndOfFile()
			fileUpdater.write(strToWrite.data(using: .utf8)!)
			fileUpdater.closeFile()
		}
	}
	
	func updateState(now: UInt64, temp: Double, sg: Double) {
		self.lastUpdatedTime = now
		self.currentTemp = temp
		self.currentGravity = sg
		self.sgReadings.append((self.lastUpdatedTime, self.currentGravity))
		self.currentAbv = self.calculateAbv(originalSg: self.sgReadings[0].1, currentSg: self.currentGravity)
	}
	
	func calculateAbv(originalSg: Double, currentSg: Double) -> Double {
		let abv = (76.08 * (originalSg - currentSg) / (1.775 - originalSg)) * (currentSg / 0.794)
		return abv
	}
	
	func start() -> HydrometerState {
		do {
			try self.buildLogFileUrl()
			try self.createLogFile()
			try self.readLogFile()
		} catch {
			print(error.localizedDescription)
		}
		return self
	}
}
