//
//  HydrometerApp.swift
//  Created by Michael Simms on 8/18/22.
//

import SwiftUI
import CoreLocation
import TabularData

let PREF_NAME_LOG_FILE_NAME = "Log File Name"
let DEFAULT_LOG_FILE_NAME = "log.csv"
let HYDROMETER_NAMES: Array<String> = [ "Red", "Green", "Black", "Purple", "Orange", "Blue", "Yellow", "Pink" ]
let HYDROMETER_COLORS: Array<Color> = [ .red, .green, .black, .purple, .orange, .blue, .yellow, .pink ]
var HYDROMETER_IDS: Array<UUID> = []

func dataToUUID(data: Data) -> UUID {
	var uuidStr: String = ""
	for i in 0...3 {
		uuidStr += String(data[i], radix: 16)
	}
	uuidStr += "-"
	for i in 4...5 {
		uuidStr += String(data[i], radix: 16)
	}
	uuidStr += "-"
	for i in 6...7 {
		uuidStr += String(data[i], radix: 16)
	}
	uuidStr += "-"
	for i in 8...9 {
		uuidStr += String(data[i], radix: 16)
	}
	uuidStr += "-"
	for i in 10...15 {
		uuidStr += String(data[i], radix: 16)
	}
	
	let uuid8 = UUID(uuidString: uuidStr)!
	return uuid8
}

class HydrometerAppState : ObservableObject {

	static let shared = HydrometerAppState()

	private var beaconScanner: LocationSensor = LocationSensor()
	private var hydrometerStates: Array<HydrometerState> = []

	/// Constructor
	private init() {
		HYDROMETER_IDS.append(dataToUUID(data: CUSTOM_BT_SERVICE_TILT_HYDROMETER1))
		HYDROMETER_IDS.append(dataToUUID(data: CUSTOM_BT_SERVICE_TILT_HYDROMETER2))
		HYDROMETER_IDS.append(dataToUUID(data: CUSTOM_BT_SERVICE_TILT_HYDROMETER3))
		HYDROMETER_IDS.append(dataToUUID(data: CUSTOM_BT_SERVICE_TILT_HYDROMETER4))
		HYDROMETER_IDS.append(dataToUUID(data: CUSTOM_BT_SERVICE_TILT_HYDROMETER5))
		HYDROMETER_IDS.append(dataToUUID(data: CUSTOM_BT_SERVICE_TILT_HYDROMETER6))
		HYDROMETER_IDS.append(dataToUUID(data: CUSTOM_BT_SERVICE_TILT_HYDROMETER7))
		HYDROMETER_IDS.append(dataToUUID(data: CUSTOM_BT_SERVICE_TILT_HYDROMETER8))
		
		for (hydrometerId, (hydrometerName, hydrometerColor)) in zip(HYDROMETER_IDS, zip(HYDROMETER_NAMES, HYDROMETER_COLORS)) {
			hydrometerStates.append(HydrometerState(id: hydrometerId, name: hydrometerName, color: hydrometerColor))
		}
	}

	func selectedHydrometerByName(name: String) -> HydrometerState {
		for state in self.hydrometerStates {
			if state.hydrometerName == name {
				return state
			}
		}
		return self.hydrometerStates[0]
	}
	
	func selectedHydrometerById(id: UUID) -> HydrometerState {
		for state in self.hydrometerStates {
			if state.hydrometerId == id {
				return state
			}
		}
		return self.hydrometerStates[0]
	}
	
	func hydrometerBeaconReceived(beacon: CLBeacon) -> Void {
		do {
			let now = time(nil)
			let hydrometerState = self.selectedHydrometerById(id: beacon.uuid)

			// Only update every ten minutes.
			if now > hydrometerState.lastUpdatedTime + 600 {
				hydrometerState.updateState(now: UInt64(now), temp: Double(truncating: beacon.major), sg: Double(truncating: beacon.minor) / 1000.0)
				try hydrometerState.updateLogFile()
			}
		}
		catch {
		}
	}
}

@main
struct HydrometerApp: App {
	var body: some Scene {
        WindowGroup {
			ContentView()
        }
    }
}
