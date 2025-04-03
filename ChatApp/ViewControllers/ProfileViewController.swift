//
//  ProfileViewController.swift
//  ChatApp
//
//  Created by Mac on 03/04/2025.
//

import UIKit
import FirebaseAuth
import PhotosUI
import FirebaseDatabase
import SDWebImage

protocol ProfileViewControllerDelegate: AnyObject {
    func imageUploadCompleted(url: String?)
}

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "UploadSegue" {
            let destinationVC = segue.destination as! UploadViewController
            let imageToUpload = sender as! UIImage
            destinationVC.imageToUpload = imageToUpload
            destinationVC.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameLabel.text = ""
        avatarImageView.image = UIImage(systemName: "person.fill")
        avatarImageView.tintColor = UIColor.black
        avatarImageView.backgroundColor = UIColor.lightGray
        let avatarTap = UITapGestureRecognizer(target: self, action: #selector(presentAvatarOptions))
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(avatarTap)
        getUserProfile()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        containerView.layer.cornerRadius = 8
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
    }
    
    func getUserProfile() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        UserModel.reference.child(userId).observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let strongSelf = self else { return }
            if let user = UserModel(snapshot: snapshot) {
                strongSelf.avatarImageView.sd_setImage(with: user.avatarURL, placeholderImage: UIImage(systemName: "person.fill"))
                strongSelf.usernameLabel.text = "@\(user.username)"
            }
        }
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
            let authStoryboard = UIStoryboard(name: "Auth", bundle: nil)
            let signinVC = authStoryboard.instantiateViewController(withIdentifier: "SignInViewController")
            let window = UIApplication.shared.connectedScenes.flatMap { ($0 as? UIWindowScene)?.windows ?? [] }.first { $0.isKeyWindow }
            window?.rootViewController = signinVC
            
        } catch {
            presentErrorAlert(title: "Logout Failed", message: "Something went wrong with logout. Please try again later.")
        }
    }
    
    @objc func presentAvatarOptions() {
        let avatarOptionsSheet = UIAlertController(title: "Change Avatar", message: "Select an option.", preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { _ in
            self.performSegue(withIdentifier: "UploadSegue", sender: nil)
        }
        let photoAction = UIAlertAction(title: "Photo", style: .default) { _ in
            var config = PHPickerConfiguration()
            config.filter = PHPickerFilter.images
            config.selectionLimit = 1
            let pickerViewController = PHPickerViewController(configuration: config)
            pickerViewController.delegate = self
            self.present(pickerViewController, animated: true)
        }
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        avatarOptionsSheet.addAction(cameraAction)
        avatarOptionsSheet.addAction(photoAction)
        avatarOptionsSheet.addAction(deleteAction)
        avatarOptionsSheet.addAction(cancelAction)
        present(avatarOptionsSheet, animated: true)
    }
    
    @IBAction func dimissButtonTapped(_ sender: Any) {
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

extension ProfileViewController: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let result = results.first else { return }
        result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
            guard let strongSelf = self else { return }
            if let error = error {
                print(error.localizedDescription)
                return
            }
            if let image = object as? UIImage {
                DispatchQueue.main.async {
                    strongSelf.performSegue(withIdentifier: "UploadSegue", sender: image)
                }
            }
        }
    }
    
}

extension ProfileViewController: ProfileViewControllerDelegate {
    
    func imageUploadCompleted(url: String?) {
        guard let url = url,
        let userId = Auth.auth().currentUser?.uid else {
            presentErrorAlert(title: "Failed to Upload", message: "Something went wrong uploading your avatar.")
            return
        }
        avatarImageView.sd_setImage(with: URL(string: url))
        Database.database().reference().child("users").child(userId).updateChildValues(["avatarURL": url])
    }
    
}
