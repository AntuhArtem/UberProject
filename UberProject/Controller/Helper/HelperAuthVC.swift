//
//  HelperAuthVC.swift
//  UberProject
//
//  Created by Artem Antuh on 9/5/18.
//  Copyright © 2018 Artem Antuh. All rights reserved.
//

import UIKit
import FirebaseAuth

class HelperAuthVC: UIViewController, UITextFieldDelegate {

    private let helperSegue = "HelperMapVC";
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    
    @IBAction func logIn(_ sender: UIButton) {
        if emailTextField.text != "" && passwordTextField.text != "" {
            AuthProvider.Instance.login(withEmail: emailTextField.text!, password: passwordTextField.text!, loginHandler: {(message) in
                            
                                            if message != nil {
                                                self.alertTheUser(title: "Problem With Authentication", message: message!)
                                            }
                                            else
                                            {
                                                UberHandler.Instance.helper = self.emailTextField.text!
                                                self.emailTextField.text = ""
                                                self.passwordTextField.text = ""
                                                self.performSegue(withIdentifier: self.helperSegue, sender: nil)
                                            }
            })
        }
        else
        {
            alertTheUser(title: "Email And Password Are Required",
                         message: "Please Enter Email And Password ")
        }
    }
    
    
    
    
    @IBAction func signUp(_ sender: UIButton) {
        if emailTextField.text != "" && passwordTextField.text != "" {
            AuthProvider.Instance.signUp(withEmail: emailTextField.text!, password: passwordTextField.text!, loginHandler: {(message) in
                
                if message != nil {
                    self.alertTheUser(title: "Problem With Creating User", message: message!)
                }
                else
                {
                    UberHandler.Instance.helper = self.emailTextField.text!
                    self.emailTextField.text = ""
                    self.passwordTextField.text = ""
                    self.performSegue(withIdentifier: self.helperSegue, sender: nil)
                }
            })
        }
        else
        {
            alertTheUser(title: "Email And Password Are Required",
                         message: "Please Enter Email And Password ")
        }
    }
    
    
    
    @IBAction func backToLaunchScreen(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    private func alertTheUser(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
}
