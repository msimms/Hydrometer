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

	func startScanning() {
		for (hydrometerId, hydrometerName) in zip(HYDROMETER_IDS, HYDROMETER_NAMES) {
			self.locationManager.startMonitoring(for: CLBeaconRegion(uuid: hydrometerId, identifier: hydrometerName))
			self.locationManager.startRangingBeacons(satisfying: CLBeaconIdentityConstraint(uuid: hydrometerId))
		}
	}
}
