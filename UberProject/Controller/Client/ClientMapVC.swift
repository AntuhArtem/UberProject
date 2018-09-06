//
//  ClientMapVC.swift
//  UberProject
//
//  Created by Artem Antuh on 9/5/18.
//  Copyright © 2018 Artem Antuh. All rights reserved.
//

import UIKit
import MapKit

class ClientMapVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, Controlable {
    func acceptUber(lat: Double, long: Double) {
    }
    
    func clientCanceledUber() {
    }
    
    func uberCanceled() {
    }
    
    func updateClientsLocation(lat: Double, long: Double) {
    }
    
    func cancelUberForhelper() {
    }
    
    func uberAccepted(lat: Double, long: Double) {
    }
    

    @IBOutlet weak var myMap: MKMapView!
    @IBOutlet weak var callUberBtn: UIButton!
    
    private var locationManager = CLLocationManager()
    private var userLocation: CLLocationCoordinate2D?
    private var helperLocation: CLLocationCoordinate2D?
    
    private var timer = Timer()
    
    private var canCallUber = true
    private var clientCanceledRequest = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeLocationManager()
        UberHandler.Instance.observeMessagesForClient()
        UberHandler.Instance.delegate = self
    }
    
    
    private func initializeLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //if we have coordinates from the manager
        if let location = locationManager.location?.coordinate {
            
            userLocation = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            
            //setting up navigation region
            let region = MKCoordinateRegion(center: userLocation!, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            myMap.setRegion(region, animated: true)
            myMap.removeAnnotations(myMap.annotations)
            
            if helperLocation != nil {
                if !canCallUber {
                    let helperAnnotation = MKPointAnnotation()
                    helperAnnotation.coordinate = helperLocation!
                    helperAnnotation.title = "Helper location"
                    myMap.addAnnotation(helperAnnotation)
                }
            }
            let annotation = MKPointAnnotation()
            annotation.coordinate = userLocation!
            annotation.title = "Helpers Location"
            myMap.addAnnotation(annotation)
        }
    }
    
    
    func updateClientsLocation() {
        UberHandler.Instance.updateClientsLocation(lat: userLocation!.latitude,
                                                 long: userLocation!.longitude)
    }
    
    
    func canCallUber(delegateCalled: Bool) {
        if delegateCalled {
            callUberBtn.setTitle("Cancel Uber", for: UIControlState.normal)
            canCallUber = false
        }
        else
        {
            callUberBtn.setTitle("Call Uber", for: UIControlState.normal)
            canCallUber = true
            UberHandler.Instance.cancelUber()
        }
    }
    
    
    func helperAcceptedRequest(requestAccepted: Bool, helperName: String) {
        if !clientCanceledRequest {
            if requestAccepted {
                alertTheUser(title: "Uber Accepted", message: "\(helperName) accepted your request")
            }
            else
            {
                UberHandler.Instance.cancelUber()
                timer.invalidate()
                alertTheUser(title: "Uber canceled", message: "\(helperName) cancel Uber request")
            }
        }
        clientCanceledRequest = false
    }
    
    func updateHelpersLocation(lat: Double, long: Double) {
        helperLocation = CLLocationCoordinate2D(latitude: lat, longitude: long)
    }
    
    
   
    @IBAction func callUber(_ sender: UIButton) {
        if userLocation != nil {
            if canCallUber {
                UberHandler.Instance.requestUber(latitude: Double(userLocation!.latitude),
                                                 longitude: Double(userLocation!.longitude))
                //                timer = Timer.scheduledTimer(timeInterval: 10,
                //                                             target: self,
                //                                             selector: #selector(RiderVC.updateRidersLocation),
                //                                             userInfo: nil,
                //                                             repeats: true)
            }
            else
            {
                clientCanceledRequest = true
                UberHandler.Instance.cancelUber()
                timer.invalidate()
                // cancel uber
            }
        }
    }
    
    
    
    @IBAction func logOut(_ sender: UIButton) {
        if AuthProvider.Instance.logOut() {
            if !canCallUber {
                UberHandler.Instance.cancelUber()
                timer.invalidate()
            }
            dismiss(animated: true, completion: nil)
        }
        else
        {
            //problem
            alertTheUser(title: "Could Not LogOut", message: "Try later")
        }
    }
    
    
    
    private func alertTheUser(title: String, message: String) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert);
        let ok = UIAlertAction(title: "OK",
                               style: .default,
                               handler: nil);
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
}
