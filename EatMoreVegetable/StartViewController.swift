//
//  StartViewController.swift
//  EatMoreVegetable
//
//  Created by Rapsodo Mobile 6 on 8.01.2020.
//  Copyright © 2020 Rapsodo Mobile 6. All rights reserved.
//

import UIKit
import Firebase

class StartViewController: ViewController {

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool){
        super.viewDidAppear(animated)
        if Auth.auth().currentUser != nil {
            let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            if let vc = mainStoryboard.instantiateViewController(withIdentifier: "EatMoreVegetableViewController") as? EatMoreVegetableViewController {
                
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    fileprivate func setupUI() {
        loginButton.layer.borderWidth = 1
        loginButton.layer.borderColor = UIColor.white.cgColor
        
        signupButton.layer.borderWidth = 1
        signupButton.layer.borderColor = UIColor.white.cgColor
    }
    
    @IBAction func loginTapped(_ sender: UIButton) {
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        if let vc = mainStoryboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController {
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    @IBAction func signupTapped(_ sender: UIButton) {
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        if let vc = mainStoryboard.instantiateViewController(withIdentifier: "SignUpViewController") as? SignUpViewController {
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}
