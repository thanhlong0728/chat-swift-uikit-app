//
//  CreateRoomViewController.swift
//  ChatApp
//
//  Created by Mac on 03/04/2025.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

//Time since epoch

class CreateRoomViewController: UIViewController {
    
    @IBOutlet weak var roomTitleTextField: UITextField!
    @IBOutlet weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        containerView.layer.cornerRadius = 8
    }
    
    @IBAction func createRoomButtonTapped(_ sender: Any) {
        
        guard let userId = Auth.auth().currentUser?.uid else {
            return
        }
        
        guard let roomTitle = roomTitleTextField.text,
              roomTitle.count >= 3 && roomTitle.count <= 12 else {
            presentErrorAlert(title: "Invalid Room Title", message: "Your room title needs to be between 3 and 12 characters long.")
            return
        }
        Database.database().reference().child("rooms").child(roomTitle).observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let strongSelf = self else { return }
            if snapshot.exists() {
                strongSelf.presentErrorAlert(title: "Room Title In Use", message: "Please choose a different room title.")
                return
            }
            
            let createdAt: Double = Date().timeIntervalSince1970
            var roomDetails: [String: Any] = ["title": roomTitle, "createdAt": createdAt, "userId": userId]
            
            UserModel.reference.child(userId).observeSingleEvent(of: .value) { snapshot in
                if let user = UserModel(snapshot: snapshot) {
                    if let avatarURL = user.avatarURL {
                        roomDetails["avatarURL"] = avatarURL.absoluteString
                    }
                }
                Database.database().reference().child("rooms").child(roomTitle).setValue(roomDetails)
                strongSelf.dismiss(animated: true)
            }
            
        }
        
    }
    
    @IBAction func dismissButtonTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    

}
