//
//  AuthProvider.swift
//  UberProject
//
//  Created by Artem Antuh on 9/5/18.
//  Copyright © 2018 Artem Antuh. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth

typealias LoginHandler = (_ msg: String?) -> Void;

struct LoginnErrorCode{
    static let invalidEmail = "Invalid Email Address, Please Provide A Real Email Address";
    static let wrongPassword = "Wrong Password, Please Enter Correct Password";
    static let problemConnecting = "Problem Connecting To Database, Try Later";
    static let userNotFound = "User Not Found, Please Register";
    static let emailAlreadyInUse = "Email Already In Use, Enter Another Email";
    static let weakPassword = "Password Should Be At Least 6 Characters Long";
}

class AuthProvider {
    private static let staticInstance = AuthProvider();
    static var Instance: AuthProvider {
        return staticInstance;
    }
    
    
    //login function
    func login(withEmail: String, password: String, loginHandler: LoginHandler?) {
        Auth.auth().signIn(withEmail: withEmail, password: password, completion: {(user, error) in
                            if error != nil {
                                self.handleErrors(err: error! as NSError, loginHandler: loginHandler)
                            }
                            else
                            {
                                loginHandler?(nil);
                            }
        });
    }
    
    
    //sign up function
    func signUp(withEmail: String, password: String, loginHandler: LoginHandler?) {
        Auth.auth().createUser(withEmail: withEmail, password: password, completion: {(user, error) in
                                if error != nil {
                                    self.handleErrors(err: error! as NSError, loginHandler: loginHandler)
                                }
                                else
                                {
                                    if user?.user.uid != nil {
                                        // store user to DB
                                        DBProvider.Instance.saveUser(withID: user!.user.uid, email: withEmail, paasword: password)
                                        //login user
                                        self.login(withEmail: withEmail, password: password, loginHandler: loginHandler)
                                    }
                                }
        })
    }
    
    
    //log out function
    func logOut() -> Bool {
        if Auth.auth().currentUser != nil {
            do {
                try Auth.auth().signOut()
                return true
            }
            catch
            {
                return false
            }
        }
        return true
    }
    
    
    //ERROR HANDLER
    private func handleErrors(err: NSError, loginHandler: LoginHandler?) {
        if let errCode = AuthErrorCode(rawValue: err.code) {
            
            switch errCode {
                
            case .wrongPassword:
                loginHandler?(LoginnErrorCode.wrongPassword);
                break;
            case .invalidEmail:
                loginHandler?(LoginnErrorCode.invalidEmail);
                break;
            case .userNotFound:
                loginHandler?(LoginnErrorCode.userNotFound);
                break;
            case .emailAlreadyInUse:
                loginHandler?(LoginnErrorCode.emailAlreadyInUse);
                break;
            case .weakPassword:
                loginHandler?(LoginnErrorCode.weakPassword);
                break;
            default :
                loginHandler?(LoginnErrorCode.problemConnecting);
                break;
            }
        }
    }
}
