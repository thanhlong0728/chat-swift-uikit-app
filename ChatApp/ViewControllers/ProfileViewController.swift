//
//  ProfileViewController.swift
//  ChatApp
//
//  Created by Mac on 03/04/2025.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        avatarImageView.image = UIImage(systemName: "person.fill")
        avatarImageView.tintColor = UIColor.black
        avatarImageView.backgroundColor = UIColor.lightGray
        let avatarTap = UITapGestureRecognizer(target: self, action: #selector(presentAvatarOptions))
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(avatarTap)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        containerView.layer.cornerRadius = 8
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
    }
    
    func logout() {
        do {
           try Auth.auth().signOut()
            let authStoryboard = UIStoryboard(name: "Auth", bundle: nil)
            let signinVC = authStoryboard.instantiateViewController(withIdentifier: "SignInViewController")
            let window = UIApplication.shared.connectedScenes.flatMap {($0 as? UIWindowScene)?.windows ?? []}.first {$0.isKeyWindow}
            window?.rootViewController = signinVC
        } catch {
            presentErrorAlert(title: "Logout Failed", message: "Something went wrong with logout. Please try again later.")
        }
    }
    
    @objc func presentAvatarOptions() {
        let avatarOptionsSheet = UIAlertController(title: "Change Avatar", message: "Select an option", preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { _ in
            
        }
        let photoAction = UIAlertAction(title: "Photo", style: .default) { _ in
            
        }
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            
        }
        
        avatarOptionsSheet.addAction(cameraAction)
        avatarOptionsSheet.addAction(photoAction)
        avatarOptionsSheet.addAction(deleteAction)
        avatarOptionsSheet.addAction(cancelAction)
        present(avatarOptionsSheet, animated: true)
    }
    
    
    @IBAction func dismissButtonTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func logoutButtonTapped(_ sender: Any) {
                let logoutAlert = UIAlertController(title: "Confirm Logout", message: "Are you sure you would like to logout of your account?", preferredStyle: .alert)
                let logoutAction = UIAlertAction(title: "Logout", style: .destructive) { _ in
                    self.logout()
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
                logoutAlert.addAction(logoutAction)
                logoutAlert.addAction(cancelAction)
                present(logoutAlert, animated: true)
    }
    
}
