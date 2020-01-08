//
//  LoginViewController.swift
//  EatMoreVegetable
//
//  Created by Rapsodo Mobile 6 on 8.01.2020.
//  Copyright © 2020 Rapsodo Mobile 6. All rights reserved.
//

import UIKit

class LoginViewController: ViewController {
    
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        loginButton.layer.borderWidth = 2
        loginButton.layer.borderColor = UIColor.white.cgColor
        
    }
    
    @IBAction func loginTapped(_ sender: UIButton) {
    }
    


}
