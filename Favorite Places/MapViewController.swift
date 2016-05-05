//
//  MapViewController.swift
//  Favorite Places
//
//  Created by Jared Allen on 3/10/16.
//  Copyright © 2016 Jared Allen. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var map: MKMapView!
    
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        if activePlace == -1 {
            
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
            
        } else {
            
            let latitude = NSString(string: favoritePlaces[activePlace]["lat"]!).doubleValue
            let longitude = NSString(string: favoritePlaces[activePlace]["lon"]!).doubleValue
            let newCoordinate = CLLocationCoordinate2DMake(latitude, longitude)
            
            let latDelta: CLLocationDegrees = 0.01
            let lonDelta: CLLocationDegrees = 0.01
            
            let span: MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
            let location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
            let region: MKCoordinateRegion = MKCoordinateRegionMake(location, span)
            
            self.map.setRegion(region, animated: true)
            
            let newAnnotation = MKPointAnnotation()
            
            newAnnotation.coordinate = newCoordinate
            newAnnotation.title = favoritePlaces[activePlace]["name"]
            
            self.map.addAnnotation(newAnnotation)

            
        }
        
        
        // Implement press gesture
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: "newFavoritePlace:")
        longPressGesture.minimumPressDuration = 2.0
        
        map.addGestureRecognizer(longPressGesture)
        
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations)
        
        let userLocation: CLLocation = locations[0]
        let latitude = userLocation.coordinate.latitude
        let longitude = userLocation.coordinate.longitude
        
        let latDelta: CLLocationDegrees = 0.01
        let lonDelta: CLLocationDegrees = 0.01
        
        let span: MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
        let location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        let region: MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        
        self.map.setRegion(region, animated: true)
        
    }

    func newFavoritePlace(gestureRecognizer: UIGestureRecognizer!) {
        
        if gestureRecognizer.state == UIGestureRecognizerState.Began {
            
            let touchPoint = gestureRecognizer.locationInView(self.map)
            let newCoordinate: CLLocationCoordinate2D = self.map.convertPoint(touchPoint, toCoordinateFromView: self.map)
            let newPlace = CLLocation(latitude: newCoordinate.latitude, longitude: newCoordinate.longitude)
           
            CLGeocoder().reverseGeocodeLocation(newPlace, completionHandler: { (placemarks, error) in
                
                var title = String()
                
                if error == nil {
                    if let pm = placemarks?[0] {
                        
                        var subThoroughfare: String = String()
                        var thoroughfare: String = String()
                        
                        if pm.subThoroughfare != nil {
                            subThoroughfare = pm.subThoroughfare!
                        }
                        
                        if pm.thoroughfare != nil {
                            thoroughfare = pm.thoroughfare!
                        }
                        
                        title = "\(subThoroughfare) \(thoroughfare)"
                        
                    }
                }
                
                if title == "" {
                    title = "Added \(NSDate())"
                }
                
                favoritePlaces.append(["name": title, "lat": "\(newCoordinate.latitude)", "lon": "\(newCoordinate.longitude)"])
                
                let newAnnotation = MKPointAnnotation()
                
                newAnnotation.coordinate = newCoordinate
                newAnnotation.title = title
                
                self.map.addAnnotation(newAnnotation)
            })

        }
        
        
    }


}

