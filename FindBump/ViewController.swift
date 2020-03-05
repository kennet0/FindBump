//
//  ViewController.swift
//  FindBump
//
//  Created by Jang Han on 2019/11/05.
//  Copyright © 2019 Jang Han. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreMotion

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, HomeModelDelegate {
   
    
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var mapView: MKMapView!
    
   
    @IBAction func onUpdate(_ sender: Any) {
         locationManager.startUpdatingLocation()
        
        let latitude =  locationManager.location?.coordinate.latitude
        let longitude = locationManager.location?.coordinate.longitude
        gyroScpoe(latitude: latitude!, longitude: longitude!)
        
     }
     
     @IBAction func offUpdate(_ sender: Any) {
        locationManager.stopUpdatingLocation()
      
     }
    
    let locationManager = CLLocationManager()
    let regionInMeters: Double = 10000
    var motionManager = CMMotionManager()
    var speed = CLLocationSpeed()
    var homeModel = HomeModel()
    var dbLocation = [Location]()
    
    func itemsDownloaded(locations: [Location]) {
        self.dbLocation = locations
        for i in dbLocation{
            let latitude = Double(i.latitude)
            let longitude = Double(i.longitude)
            //if let lat = latitude, let long = longitude{
                addAnnotation(latitude: latitude!, longitude: longitude!, number: i.number)
            //}
       }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        homeModel.getItems()
        homeModel.delegate = self
        
        checkLocationServices()
        
         
    }
    
    func checkLocationServices() {
          if CLLocationManager.locationServicesEnabled() {
              setupLocationManager()
              checkLocationAuthorization()
          } else {
              // Show alert letting the user know they have to turn this on.
          }
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func checkLocationAuthorization() {

            switch CLLocationManager.authorizationStatus() {
            case .authorizedWhenInUse:
                  mapView.showsUserLocation = true
                  centerViewOnUserLocation()
                  
                  break
            case .denied:
                  // Show alert instructing them how to turn on permissions
                  break
            case .notDetermined:
                  locationManager.requestWhenInUseAuthorization()
            case .restricted:
                  // Show an alert letting them know what's up
                  break
            case .authorizedAlways:
                  break
        }
    }
        
    func centerViewOnUserLocation() {
           if let location = locationManager.location?.coordinate {
               let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
               mapView.setRegion(region, animated: true)
           }
       }
          
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.last else {return}
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
        mapView.setRegion(region, animated: true)
       
    }
    
    
    func gyroScpoe(latitude:CLLocationDegrees, longitude:CLLocationDegrees){
        guard let _:CLLocationDegrees = latitude else {return}
        
        motionManager.gyroUpdateInterval = 1
        motionManager.startGyroUpdates(to: OperationQueue.current!) { (data, error) in
          //  if self.speed < 30{
                if let myData = data{
                    print(myData.rotationRate.z)
                   
                    if abs(myData.rotationRate.z) > 0.2{
                        self.label.text = "\(myData.rotationRate.z)"
                        print("Coordinate : \(latitude)")
                        self.addAnnotation(latitude: latitude, longitude: longitude, number: "live")
                        self.homeModel.dbUpdate(latitude: latitude, longitude: longitude)
                   }
                }
            //}
        }
    }
    
    func addAnnotation(latitude:CLLocationDegrees, longitude:CLLocationDegrees, number:String){
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude:longitude )
        annotation.title = number
        
        self.mapView.addAnnotation(annotation)
    }
   
    
}


