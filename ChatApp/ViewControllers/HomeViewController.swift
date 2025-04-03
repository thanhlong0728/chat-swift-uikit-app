//
//  HomeViewController.swift
//  ChatApp
//
//  Created by mac on 1/4/2025.
//

import UIKit
import FirebaseAuth

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    
  
    
    @IBAction func profileButtonTapped(_ sender: Any) {
        
        performSegue(withIdentifier: "ProfileSegue", sender: nil)
        

    }
}
