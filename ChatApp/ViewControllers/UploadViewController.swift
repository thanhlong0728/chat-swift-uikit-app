//
//  UploadViewController.swift
//  ChatApp
//
//  Created by Mac on 03/04/2025.
//

import UIKit
import FirebaseStorage
import FirebaseAuth

//images/userid/image.jpeg

class UploadViewController: UIViewController {
    
    @IBOutlet weak var uploadAvatarLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var cancelButton: UIButton!
    var imageToUpload: UIImage!
    var storageTask: StorageUploadTask?
    weak var delegate: ProfileViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uploadAvatarLabel.textColor = UIColor.white
        uploadAvatarLabel.font = Font.body
        cancelButton.setTitleColor(UIColor.white, for: .normal)
        cancelButton.titleLabel?.font = Font.body
        progressView.tintColor = UIColor.white
        progressView.trackTintColor = UIColor.lightGray
        view.backgroundColor = UIColor.white.withAlphaComponent(0)
        let blurEffect = UIBlurEffect(style: .dark)
        let visualEffectView = UIVisualEffectView(effect: blurEffect)
        visualEffectView.frame = view.bounds
        view.addSubview(visualEffectView)
        view.sendSubviewToBack(visualEffectView)
        progressView.setProgress(0, animated: false)
        uploadImage()
    }
    
    func uploadImage() {
        guard let imageData = imageToUpload.jpegData(compressionQuality: 0.75) else {
            dismiss(animated: true) {
                self.delegate?.imageUploadCompleted(url: nil)
            }
            return
        }
        guard let userId = Auth.auth().currentUser?.uid else {
            dismiss(animated: true) {
                self.delegate?.imageUploadCompleted(url: nil)
            }
            return
        }
        let imageId = UUID().uuidString.lowercased().replacingOccurrences(of: "-", with: "_")
        let imageName = imageId + ".jpeg"
        let imagePath = "images/\(userId)/\(imageName)"
        let storageRef = Storage.storage().reference(withPath: imagePath)
        let metaData = StorageMetadata()
        metaData.contentType = "image/jepg"
        storageTask = storageRef.putData(imageData, metadata: metaData) { [weak self] _, error in
            guard let strongSelf = self else { return }
            if let error = error {
                print(error.localizedDescription)
                strongSelf.dismiss(animated: true) {
                    strongSelf.delegate?.imageUploadCompleted(url: nil)
                }
                return
            }
            storageRef.downloadURL { url, error in
                if let error = error {
                    print(error.localizedDescription)
                    strongSelf.dismiss(animated: true) {
                        strongSelf.delegate?.imageUploadCompleted(url: nil)
                    }
                    return
                }
                if let url = url?.absoluteString {
                    strongSelf.delegate?.imageUploadCompleted(url: url)
                    strongSelf.dismiss(animated: true)
                }
            }
        }
        storageTask!.observe(.progress) { [weak self] snapshot in
            guard let strongSelf = self else { return }
            let percentComplete = Double(snapshot.progress!.completedUnitCount / snapshot.progress!.totalUnitCount)
            strongSelf.progressView.setProgress(Float(percentComplete), animated: true)
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        guard let storageTask = storageTask else { return }
        storageTask.cancel()
        dismiss(animated: true)
    }
    

}
