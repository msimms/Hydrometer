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
	
	/// Called when a peripheral is discovered.
	/// Returns true to indicate that we should connect to this peripheral and discover its services.
	func peripheralDiscovered(description: String) -> Bool {
		return true
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
