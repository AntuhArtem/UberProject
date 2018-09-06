//
//  RoundedTextField.swift
//  UberProject
//
//  Created by Artem Antuh on 9/5/18.
//  Copyright © 2018 Artem Antuh. All rights reserved.
//

import UIKit


@IBDesignable class RoundedTextField: UITextField {
    @IBInspectable var roundedTextFields: Bool = false{
        didSet {
            if roundedTextFields{
                layer.cornerRadius = frame.height / 4
            }
        }
    }
    
    override func prepareForInterfaceBuilder() {
        if roundedTextFields{
            layer.cornerRadius = frame.height / 4
        }
    }
    
    
}

