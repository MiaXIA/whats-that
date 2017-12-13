//
//  LocationFinder.swift
//  Whats_that_McX
//
//  Created by 夏蓦辰 on 2017/12/7.
//  Copyright © 2017年 GW Mobile 17. All rights reserved.
//

import Foundation
import CoreLocation

//LocationFinder protocol
protocol LocationFinderDelegate {
    func locationFound(latitude: Double, longitude: Double)
    func locationNotFound(reason: LocationFinder.FailureReason)
}

class LocationFinder: NSObject {
    
    //failure reason in protocol
    enum FailureReason: String {
        case noPermission = "Location permission not available"
        case timeout = "It took too long to find your location"
        case error = "Error finding location"
    }
    
    //call for CLLocationManager
    let locationManager = CLLocationManager()
    
    var delegate: LocationFinderDelegate?
    
    //call for timer
    var timer = Timer()
    
    //initialization
    override init() {
        super.init()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }
    
    /**
        start the timer
     */
    func startTimer() {
        cancelTimer()
        
        timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: false, block: { (timer) in
            //code that will run 10 seconds later
            self.locationManager.stopUpdatingLocation()
            self.delegate?.locationNotFound(reason: .timeout)
        })
    }
    
    /**
        stop the timer
     */
    func cancelTimer() {
        timer.invalidate()
    }
    
    /**
        check the authorization status and find the location
        @return request authorization or return the location information
     */
    func findLocation() {
        let status = CLLocationManager.authorizationStatus()
        
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            delegate?.locationNotFound(reason: .noPermission)
        case .authorizedWhenInUse:
            startTimer()
            locationManager.requestLocation()
        case .authorizedAlways:
            //do nothing - app can't get to this state
            break
        }
    }
}

//LocationFinder CLLocationManager Delegate
extension LocationFinder: CLLocationManagerDelegate {
    
    //if find the location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        cancelTimer()
        manager.stopUpdatingLocation()
        let location = locations.first!
        delegate?.locationFound(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
    }
    
    //if the aurhorization has changed
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            startTimer()
            locationManager.requestLocation()
        }
        else {
            delegate?.locationNotFound(reason: .noPermission)
        }
    }
    
    //if failure when finding the location
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        cancelTimer()
        print(error.localizedDescription)
        delegate?.locationNotFound(reason: .error)
    }
}
