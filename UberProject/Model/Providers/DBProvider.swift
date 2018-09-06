//
//  DatabaseProvider.swift
//  UberProject
//
//  Created by Artem Antuh on 9/5/18.
//  Copyright © 2018 Artem Antuh. All rights reserved.
//

import Foundation
import FirebaseDatabase

class DBProvider {
    private static let staticInstance = DBProvider()
    static var Instance: DBProvider {
        return staticInstance
    }
    
    
    
    //reference to Firebase DB
    var dbRef: DatabaseReference {
        return Database.database().reference()
    }
    
    var clientsRef: DatabaseReference {
        return dbRef.child(Constants.clients)
    }
    
    var requestRef: DatabaseReference {
        return dbRef.child(Constants.uberRequest)
    }
    
    var requestAcceptedref: DatabaseReference {
        return dbRef.child(Constants.uberAccepted)
    }
    
    //request
    
    func saveUser(withID: String, email:String, paasword: String) {
        let data: Dictionary <String, Any> = [Constants.email : email,
                                              Constants.password : paasword,
                                              Constants.isClient : true]
        clientsRef.child(withID).child(Constants.data).setValue(data)
    }
    
}

