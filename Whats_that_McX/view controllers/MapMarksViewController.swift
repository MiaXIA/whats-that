//
//  MapMarksViewController.swift
//  Whats_that_McX
//
//  Created by 夏蓦辰 on 2017/12/10.
//  Copyright © 2017年 GW Mobile 17. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import MBProgressHUD

class MapMarksViewController: UIViewController {

    //declare the variables
    @IBOutlet weak var mapView: MKMapView!
    let locationFinder = LocationFinder()
    var latitude = Double()
    var longitude = Double()
    var favorites = [Favorite]()
    let persistanceManager = PersistanceManager()
    
    //fetch the favorite arrays before the view appear
    override func viewWillAppear(_ animated: Bool) {
        favorites = persistanceManager.fetchFavorites()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MBProgressHUD.showAdded(to: self.view, animated: true)
        locationFinder.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

//reload mapview with Favorite data
extension MapMarksViewController {
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self.view, animated: true)
            
            //set map view
            self.mapView.mapType = .standard
            self.mapView.showsCompass = true
            self.mapView.showsScale = true
            
            //MKCoordinateSpan
            let latDelta = 0.05
            let longDelta = 0.05
            let currentLocationSpan:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)
            
            //set center coordinate
            let center:CLLocation = CLLocation(latitude: self.latitude, longitude: self.longitude)
            let currentRegion:MKCoordinateRegion = MKCoordinateRegion(center: center.coordinate, span: currentLocationSpan)
            
            //set show region
            self.mapView.setRegion(currentRegion, animated: true)
            //set the user's location pin
            let mypin = MKPointAnnotation()
            mypin.coordinate = CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
            mypin.title = "I'm here"
            self.mapView.addAnnotation(mypin)
            
            //set the favorite pins
            for favorite in self.favorites {
                let objectPin = MKPointAnnotation()
                objectPin.coordinate = CLLocationCoordinate2D(latitude: favorite.latitude!, longitude: favorite.longitude!)
                objectPin.title = favorite.name
                self.mapView.addAnnotation(objectPin)
            }
        }
    }
}

//LocationFinder protocol
extension MapMarksViewController: LocationFinderDelegate {
    func locationFound(latitude: Double, longitude: Double) {
        //simply save the location to show the user's pin on the map
        self.latitude = latitude
        self.longitude = longitude
    }
    
    func locationNotFound(reason: LocationFinder.FailureReason) {
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self.view, animated: true)
            let alertController = UIAlertController(title: "Problem finding location", message: reason.rawValue, preferredStyle: .alert)
            switch reason {
            case .timeout:
                let retryAction = UIAlertAction(title: "Retry", style: .default, handler: { (action) in
                    self.locationFinder.findLocation()
                })
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                
                alertController.addAction(retryAction)
                alertController.addAction(cancelAction)
            case .noPermission:
                let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                let setting = UIAlertAction(title: "Setting", style: .default, handler: { (action) -> Void in
                    let url = URL(string: UIApplicationOpenSettingsURLString)
                    if let url = url, UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                        })
                    }
                })
                alertController.addAction(cancel)
                alertController.addAction(setting)
            case .error:
                let okayAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
                alertController.addAction(okayAction)
            }
            self.present(alertController, animated: true, completion: nil)            
        }
    }
}
