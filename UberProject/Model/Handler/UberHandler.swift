//
//  UberHandler.swift
//  UberProject
//
//  Created by Artem Antuh on 9/5/18.
//  Copyright © 2018 Artem Antuh. All rights reserved.
//

import Foundation
import FirebaseDatabase

protocol Controlable: class {
    
    func canCallUber(delegateCalled: Bool)
    func helperAcceptedRequest(requestAccepted: Bool, helperName: String)
    func updateHelpersLocation(lat: Double, long: Double)
    func acceptUber(lat: Double, long: Double)
    func clientCanceledUber()
    func uberCanceled()
    func updateClientsLocation(lat: Double, long: Double)
    func cancelUberForhelper()
    func uberAccepted(lat: Double, long: Double)
    
}


class UberHandler {
    private static let staticInstance = UberHandler()
    weak var delegate: Controlable?
    
    var client = ""
    var helper = ""
    var clientId = ""
    var helperId = ""
    
    static var Instance: UberHandler {
        return staticInstance
    }
    
    
    // accepting Uber
    func uberAccepted(lat: Double, long: Double) {
        let data: Dictionary<String, Any> = [Constants.name : helper, Constants.latitude: lat,
                                             Constants.longitude: long]
        DBProvider.Instance.requestAcceptedref.childByAutoId().setValue(data)
    }
    
    
    // canceling Uber
    func cancelUberForHelper() {
        DBProvider.Instance.requestAcceptedref.child(helperId).removeValue()
    }
    
    
    // updating location
    func updateHelperLocation(lat: Double, long: Double) {
        DBProvider.Instance.requestAcceptedref.child(helperId).updateChildValues([Constants.latitude: lat, Constants.longitude: long])
    }
    

    
// MESSAGES FOR CLIENT //
    
    func observeMessagesForClient() {
        
        // client requested Uber
        DBProvider.Instance.requestRef.observe(DataEventType.childAdded) {(snapshot: DataSnapshot) in
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.name] as? String {
                    if name == self.client {
                        self.clientId = snapshot.key
                        self.delegate?.canCallUber(delegateCalled: true)
                        print("The value is \(self.clientId)")
                    }
                }
            }
        }
        
        // canceled Uber
        DBProvider.Instance.requestRef.observe(DataEventType.childRemoved) {(snapshot: DataSnapshot) in
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.name] as? String {
                    if name == self.client {
                        self.delegate?.canCallUber(delegateCalled: false)
                    }
                }
            }
        }
        
        // accepted Uber
        DBProvider.Instance.requestAcceptedref.observe(DataEventType.childAdded)
        {(snapshot: DataSnapshot) in
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.name] as? String {
                    if self.helper == "" {
                        self.helper = name
                        self.delegate?.helperAcceptedRequest(requestAccepted: true, helperName: self.helper)
                    }
                }
            }
        }
        
        //
        DBProvider.Instance.requestAcceptedref.observe(DataEventType.childRemoved) {(snapshot: DataSnapshot) in
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.name] as? String {
                    if name == self.helper {
                        self.helper = ""
                        self.delegate?.helperAcceptedRequest(requestAccepted: false, helperName: name)
                    }
                }
            }
        }
        
        //helper updating location
        DBProvider.Instance.requestAcceptedref.observe(DataEventType.childChanged){(snapshot: DataSnapshot) in
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.name] as? String {
                    if name == self.helper {
                        if let lat = data[Constants.latitude] as? Double {
                            if let long = data[Constants.longitude] as? Double {
                                self.delegate?.updateHelpersLocation(lat: lat, long: long)
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    
// MESSAGES FOR HELPER //
    
    // client requested uber
    func observeMessagesForHelper() {
        DBProvider.Instance.requestRef.observe(DataEventType.childAdded) {(snapshot: DataSnapshot) in
            if let data = snapshot.value as? NSDictionary {
                if let latitude = data[Constants.latitude] as? Double {
                    if let longitude = data[Constants.longitude] as? Double {
                        //informing helper about request
                        self.delegate?.acceptUber(lat: latitude,
                                                  long: longitude)
                    }
                }
                if let name = data[Constants.name] as? String {
                    self.client = name
                }
            }
            
            
            //client canceled uber
            DBProvider.Instance.requestRef.observe(DataEventType.childRemoved) {(DataSnapshot) in
                if let data = snapshot.value as? NSDictionary {
                    if let name = data[Constants.name] as? String {
                        if name == self.client {
                            self.client =  ""
                            self.delegate?.clientCanceledUber()
                        }
                    }
                }
            }
            
            
            //client updating location
            DBProvider.Instance.requestRef.observe(DataEventType.childChanged) { (snapshot: DataSnapshot) in
                if let data = snapshot.value as? NSDictionary {
                    if let lat = data[Constants.latitude] as? Double {
                        if let long = data[Constants.longitude] as? Double {
                            self.delegate?.updateClientsLocation(lat: lat, long: long)
                        }
                    }
                }
            }
            
            
            //helper accepts uber
            DBProvider.Instance.requestAcceptedref.observe(DataEventType.childAdded) {
                (DataSnapshot) in
                if let data = snapshot.value as? NSDictionary {
                    if let name = data[Constants.name] as? String {
                        if name == self.helper {
                            self.helperId = snapshot.key
                        }
                    }
                }
            }
            
            
            //helper canceled uber
            DBProvider.Instance.requestRef.observe(DataEventType.childRemoved) { (snapshot: DataSnapshot) in
                if let data = snapshot.value as? NSDictionary {
                    if let name = data[Constants.name] as? String {
                        if name == self.helper {
                            self.delegate?.uberCanceled()
                        }
                    }
                }
            }
        }
    }
    
    
    // request Uber
    func requestUber(latitude: Double, longitude: Double) {
        let data: Dictionary<String, Any> = [Constants.name: client,Constants.latitude: latitude,
                                             Constants.longitude: longitude]
        DBProvider.Instance.requestRef.childByAutoId().setValue(data)
    }
    
    // cancel
    func cancelUber() {
        DBProvider.Instance.requestRef.child(clientId).removeValue()
    }
    
    // update location
    func updateClientsLocation(lat: Double, long: Double) {
        DBProvider.Instance.requestRef.child(clientId).updateChildValues([Constants.latitude: lat,
                                                                          Constants.longitude: long])
    }
}
