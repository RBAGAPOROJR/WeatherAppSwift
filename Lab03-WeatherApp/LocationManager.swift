//
//  LocationManager.swift
//  Lab03-WeatherApp
//
//  Created by RNLD on 2023-11-12.
//

//import Foundation
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
    private var locationManager: CLLocationManager
    var locationUpdateHandler: ( ( CLLocation ) -> Void )?

    override init() {
        
        locationManager = CLLocationManager()
        super.init()
        locationManager.delegate = self

    }

    func requestLocationAuthorization() {
        
        locationManager.requestWhenInUseAuthorization()
        
    }
    
    func startUpdatingLocation() {
        
        locationManager.startUpdatingLocation()
        
    }
    
    func stopUpdatingLocation() {
        
        locationManager.stopUpdatingLocation()
        
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [ CLLocation ] ) {
    
        if let location = locations.last {
            
            locationUpdateHandler?( location )
            
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error ) {
        print( "Error getting location: \( error.localizedDescription )" )
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus ) {
        if status == .denied {
            
            // Handle denied permission
            
        }
    }
}
