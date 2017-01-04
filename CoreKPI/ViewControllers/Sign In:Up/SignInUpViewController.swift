//
//  SignInUpViewController.swift
//  CoreKPI
//
//  Created by Семен on 14.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import UIKit

class SignInUpViewController: UIViewController {
    
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    
    let request = Request()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set border for buttons
        self.signInButton.layer.borderWidth = 1.0
        self.signInButton.layer.borderColor = UIColor(red: 124.0/255.0, green: 77.0/255.0, blue: 255.0/255.0, alpha: 1.0).cgColor
        self.registerButton.layer.borderWidth = 1.0
        self.registerButton.layer.borderColor = UIColor(red: 0/255.0, green: 151.0/255.0, blue: 167.0/255.0, alpha: 1.0).cgColor
        
        //MARK: - Check local user_id/token and segue to TabBarView
        
        if checkLocalToken() {
            getLocalToken()
        } else {
            print("No local token in app storage")
        }
        
    }
    
    func checkLocalToken() -> Bool {
        return false
    }
    
    func getLocalToken() {
        
    }
    
}
