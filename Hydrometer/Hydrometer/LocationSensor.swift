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
				HydrometerAppState.shared.hydrometerBeaconReceived(beacon: beacon)
			}
		} else {
		}
	}
	
	func dataaToUUID(data: Data) -> UUID {
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
		let uuid1 = self.dataaToUUID(data: CUSTOM_BT_SERVICE_TILT_HYDROMETER1)
		let uuid2 = self.dataaToUUID(data: CUSTOM_BT_SERVICE_TILT_HYDROMETER2)
		let uuid3 = self.dataaToUUID(data: CUSTOM_BT_SERVICE_TILT_HYDROMETER3)
		let uuid4 = self.dataaToUUID(data: CUSTOM_BT_SERVICE_TILT_HYDROMETER4)
		let uuid5 = self.dataaToUUID(data: CUSTOM_BT_SERVICE_TILT_HYDROMETER5)
		let uuid6 = self.dataaToUUID(data: CUSTOM_BT_SERVICE_TILT_HYDROMETER6)
		let uuid7 = self.dataaToUUID(data: CUSTOM_BT_SERVICE_TILT_HYDROMETER7)
		let uuid8 = self.dataaToUUID(data: CUSTOM_BT_SERVICE_TILT_HYDROMETER8)

		let beaconRegion1 = CLBeaconRegion(uuid: uuid1, identifier: "Hydrometer1")
		let beaconRegion2 = CLBeaconRegion(uuid: uuid2, identifier: "Hydrometer2")
		let beaconRegion3 = CLBeaconRegion(uuid: uuid3, identifier: "Hydrometer3")
		let beaconRegion4 = CLBeaconRegion(uuid: uuid4, identifier: "Hydrometer4")
		let beaconRegion5 = CLBeaconRegion(uuid: uuid5, identifier: "Hydrometer5")
		let beaconRegion6 = CLBeaconRegion(uuid: uuid6, identifier: "Hydrometer6")
		let beaconRegion7 = CLBeaconRegion(uuid: uuid7, identifier: "Hydrometer7")
		let beaconRegion8 = CLBeaconRegion(uuid: uuid8, identifier: "Hydrometer8")

		self.locationManager.startMonitoring(for: beaconRegion1)
		self.locationManager.startMonitoring(for: beaconRegion2)
		self.locationManager.startMonitoring(for: beaconRegion3)
		self.locationManager.startMonitoring(for: beaconRegion4)
		self.locationManager.startMonitoring(for: beaconRegion5)
		self.locationManager.startMonitoring(for: beaconRegion6)
		self.locationManager.startMonitoring(for: beaconRegion7)
		self.locationManager.startMonitoring(for: beaconRegion8)

		self.locationManager.startRangingBeacons(in: beaconRegion1)
		self.locationManager.startRangingBeacons(in: beaconRegion2)
		self.locationManager.startRangingBeacons(in: beaconRegion3)
		self.locationManager.startRangingBeacons(in: beaconRegion4)
		self.locationManager.startRangingBeacons(in: beaconRegion5)
		self.locationManager.startRangingBeacons(in: beaconRegion6)
		self.locationManager.startRangingBeacons(in: beaconRegion7)
		self.locationManager.startRangingBeacons(in: beaconRegion8)
	}
}
