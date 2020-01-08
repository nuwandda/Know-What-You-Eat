//
//  LoginViewController.swift
//  EatMoreVegetable
//
//  Created by Rapsodo Mobile 6 on 8.01.2020.
//  Copyright © 2020 Rapsodo Mobile 6. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: ViewController {
    
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        
    }
    
    fileprivate func setupUI() {
        loginButton.layer.borderWidth = 2
        loginButton.layer.borderColor = UIColor.white.cgColor
    }
    
    @IBAction func loginTapped(_ sender: UIButton) {
        
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
           if error == nil{
             let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
             if let vc = mainStoryboard.instantiateViewController(withIdentifier: "EatMoreVegetableViewController") as? EatMoreVegetableViewController {
                 
                 self.navigationController?.pushViewController(vc, animated: true)
             }
                          }
            else{
             let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
             let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                            
              alertController.addAction(defaultAction)
              self.present(alertController, animated: true, completion: nil)
                 }
        }
    }
    


}
