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
	func buildLogFileUrl(location: String) throws -> URL? {
		
		var logFileUrl: URL?
		
		// Build the URL for the vault's directory. If a location was provided then
		// use it, otherwise assume the user's iCloud directory.
		if location.count == 0 {
			logFileUrl = FileManager.default.url(forUbiquityContainerIdentifier: nil)
			if logFileUrl == nil {
				throw LogFileException.runtimeError("iCloud storage is disabled.")
			}
		}
		else {
			logFileUrl = URL(string: location)
		}
		logFileUrl = logFileUrl?.appendingPathComponent("Hydrometer")
		try FileManager.default.createDirectory(at: logFileUrl!, withIntermediateDirectories: true, attributes: nil)

		// Build the URL for the vault's master file.
		return logFileUrl?.appendingPathComponent("log.csv", isDirectory: false)
	}

	func createLogFile() {
		do {
			let logFileUrl = try buildLogFileUrl(location: "")

			if !FileManager.default.fileExists(atPath: logFileUrl!.path) {

				// Create the parent directory.
				try FileManager.default.createDirectory(at: logFileUrl!, withIntermediateDirectories: true, attributes: nil)

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
	
	/// Called when a peripheral is discovered.
	/// Returns true to indicate that we should connect to this peripheral and discover its services.
	func peripheralDiscovered(description: String) -> Bool {
		if description.contains("Tilt") || description.contains("Hydrometer") {
			print(description)
			return true
		}
		return false
	}
	
	/// Called when a service is discovered.
	func serviceDiscovered(serviceId: CBUUID) {
	}
	
	/// Called when a sensor characteristic is updated.
	func valueUpdated(peripheral: CBPeripheral, serviceId: CBUUID, value: Data) {
		if  serviceId == CBUUID(data: CUSTOM_BT_SERVICE_TILT_HYDROMETER1) ||
			serviceId == CBUUID(data: CUSTOM_BT_SERVICE_TILT_HYDROMETER2) ||
			serviceId == CBUUID(data: CUSTOM_BT_SERVICE_TILT_HYDROMETER3) ||
			serviceId == CBUUID(data: CUSTOM_BT_SERVICE_TILT_HYDROMETER4) ||
			serviceId == CBUUID(data: CUSTOM_BT_SERVICE_TILT_HYDROMETER5) ||
			serviceId == CBUUID(data: CUSTOM_BT_SERVICE_TILT_HYDROMETER6) ||
			serviceId == CBUUID(data: CUSTOM_BT_SERVICE_TILT_HYDROMETER7) ||
			serviceId == CBUUID(data: CUSTOM_BT_SERVICE_TILT_HYDROMETER8) {

			let (rawTemperature, rawGravity) = decodeHydrometerReading(data: value)
			self.currentTemp = convertTemperature(temperature: rawTemperature)
			self.currentGravity = convertGravity(gravity: rawGravity)
			storeReading()
		}
	}

	func startBluetoothScanning() -> BluetoothScanner {

		createLogFile()

		let scanner = BluetoothScanner()
		let interestingServices = [ CBUUID(data: CUSTOM_BT_SERVICE_TILT_HYDROMETER1),
									CBUUID(data: CUSTOM_BT_SERVICE_TILT_HYDROMETER2),
									CBUUID(data: CUSTOM_BT_SERVICE_TILT_HYDROMETER3),
									CBUUID(data: CUSTOM_BT_SERVICE_TILT_HYDROMETER4),
									CBUUID(data: CUSTOM_BT_SERVICE_TILT_HYDROMETER5),
									CBUUID(data: CUSTOM_BT_SERVICE_TILT_HYDROMETER6),
									CBUUID(data: CUSTOM_BT_SERVICE_TILT_HYDROMETER7),
									CBUUID(data: CUSTOM_BT_SERVICE_TILT_HYDROMETER8) ]
		
		// Start scanning for the services that we are interested in.
		scanner.startScanning(serviceIdsToScanFor: interestingServices,
							  peripheralCallbacks: [peripheralDiscovered],
							  serviceCallbacks: [serviceDiscovered],
							  valueUpdatedCallbacks: [valueUpdated])
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
