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
		
		var logDirUrl: URL?
		
		// Build the URL for the vault's directory. If a location was provided then
		// use it, otherwise assume the user's iCloud directory.
		if location.count == 0 {
			logDirUrl = FileManager.default.url(forUbiquityContainerIdentifier: nil)
			if logDirUrl == nil {
				throw LogFileException.runtimeError("iCloud storage is disabled.")
			}
		}
		else {
			logDirUrl = URL(string: location)
		}
		logDirUrl = logDirUrl?.appendingPathComponent("Hydrometer")

		// Build the URL for the vault's master file.
		return logDirUrl?.appendingPathComponent("log.csv")
	}

	func createLogFile() {
		do {
			let logFileUrl = try buildLogFileUrl(location: "")
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
		print(description)
		if description.contains("Tilt") || description.contains("Hydrometer") {
			createLogFile()
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
