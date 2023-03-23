//
//  LocationSensor.swift
//  Created by Michael Simms on 2/8/23.
//

import Foundation
import CoreLocation

class LocationSensor : NSObject, CLLocationManagerDelegate {
	var locationManager: CLLocationManager = CLLocationManager()
	var currentLocation: CLLocation = CLLocation()
	var minAllowedHorizontalAccuracy: CLLocationAccuracy = 0.0
	var minAllowedVerticalAccuracy: CLLocationAccuracy = 0.0
	var discardBadDataPoints: Bool = false
	var hydrometerIds: Array<UUID> = []

	override init() {
		super.init()
		
		self.locationManager.delegate = self
		self.locationManager.activityType = CLActivityType.other
		self.locationManager.distanceFilter = kCLDistanceFilterNone
		self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
		self.locationManager.allowsBackgroundLocationUpdates = true
		self.locationManager.requestAlwaysAuthorization()
	}

	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		if status == .authorizedAlways {
			if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
				if CLLocationManager.isRangingAvailable() {
					self.startScanning()
				}
			}
		}
	}

	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
	}

	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
	}

	func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
		if beacons.count > 0 {
			for beacon in beacons {
				HydrometerAppState.shared.hydrometerBeaconReceived(beacon: beacon, hydrometerIds: self.hydrometerIds)
			}
		} else {
		}
	}
	
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

	func startScanning() {
		self.hydrometerIds.append(self.dataToUUID(data: CUSTOM_BT_SERVICE_TILT_HYDROMETER1))
		self.hydrometerIds.append(self.dataToUUID(data: CUSTOM_BT_SERVICE_TILT_HYDROMETER2))
		self.hydrometerIds.append(self.dataToUUID(data: CUSTOM_BT_SERVICE_TILT_HYDROMETER3))
		self.hydrometerIds.append(self.dataToUUID(data: CUSTOM_BT_SERVICE_TILT_HYDROMETER4))
		self.hydrometerIds.append(self.dataToUUID(data: CUSTOM_BT_SERVICE_TILT_HYDROMETER5))
		self.hydrometerIds.append(self.dataToUUID(data: CUSTOM_BT_SERVICE_TILT_HYDROMETER6))
		self.hydrometerIds.append(self.dataToUUID(data: CUSTOM_BT_SERVICE_TILT_HYDROMETER7))
		self.hydrometerIds.append(self.dataToUUID(data: CUSTOM_BT_SERVICE_TILT_HYDROMETER8))
		
		for (hydrometerId, hydrometerName) in zip(self.hydrometerIds, HydrometerAppState.shared.hydrometerNames) {
			self.locationManager.startMonitoring(for: CLBeaconRegion(uuid: hydrometerId, identifier: hydrometerName))
			self.locationManager.startRangingBeacons(satisfying: CLBeaconIdentityConstraint(uuid: hydrometerId))
		}
	}
}
