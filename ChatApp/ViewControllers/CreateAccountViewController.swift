//
//  CreateAccountViewController.swift
//  ChatApp
//
//  Created by mac on 1/4/2025.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class CreateAccountViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signinAccountTextView: UITextView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    var activeTextField: UITextField?

    override func viewDidLoad() {
        super.viewDidLoad()
        containerView.clipsToBounds = true
        containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        let attributedString = NSMutableAttributedString(string: "Already have an account? Sign in here", attributes: [.font: Font.caption])
        attributedString.addAttribute(.link, value: "chatappcreate://createAccount", range: (attributedString.string as NSString).range(of: "Sign in here"))
        signinAccountTextView.attributedText = attributedString
        signinAccountTextView.linkTextAttributes = [.foregroundColor: UIColor.secondary, .font: Font.linkLabel]
        signinAccountTextView.delegate = self
        signinAccountTextView.isScrollEnabled = false
        signinAccountTextView.textAlignment = .center
        signinAccountTextView.isEditable = false
        usernameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        let backgroundTap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(backgroundTap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerKeyboardNotification()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeKeyboardNotifications()
    }
    
    func registerKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification: )), name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification: )), name: UIWindow.keyboardDidHideNotification, object: nil)
    }
    
    func removeKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIWindow.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIWindow.keyboardDidHideNotification, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        containerView.layer.cornerRadius = 20
    }
    
    @objc func keyboardWillShow(notification: NSNotification){
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        
        let keyboardOffset = view.convert(keyboardFrame.cgRectValue, from: nil).size.height
        let totalOffset = activeTextField == nil ? keyboardOffset : keyboardOffset + activeTextField!.frame.height
        scrollView.contentInset.bottom = totalOffset
    }
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
    
    @objc func keyboardWillHide(notification: NSNotification){
        scrollView.contentInset.bottom = 0
    }
    
    @IBAction func createAccountButtonTapped(_ sender: Any) {
        guard let username = usernameTextField.text else{
           presentErrorAlert(title: "Username Required", message: "Please enter a username to continue.")
            return
        }
        guard username.count >= 1 && username.count <= 15 else {
            presentErrorAlert(title: "Username Invalid", message: "Please enter a username between 1 and 15 characters long.")
            return
        }
        guard let password = passwordTextField.text else {
            presentErrorAlert(title: "Password Required", message: "Please enter a password to continue.")
            return
        }
        guard let email = emailTextField.text else { 
            presentErrorAlert(title: "Email Required", message: "Please enter an email to continue.")
            return
        }
        showLoadingView()

        Database.database().reference().child("usernames").child(username).observeSingleEvent(of: .value) { snapshot in
            guard !snapshot.exists() else {
                self.presentErrorAlert(title: "Username In Use", message: "Please try a different username")
                self.removeLoadingView()
                return
            }
            
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                self.removeLoadingView()
                if let error = error {
                    print(error.localizedDescription)
                    var errorMessage = "Something went wrong. Please try again later."
                    if let authError = AuthErrorCode(rawValue: error._code) {
                        switch authError {
                        case .emailAlreadyInUse:
                            errorMessage = "Email already is use"
                        case .invalidEmail:
                            errorMessage = "Invalid Email"
                        case .weakPassword:
                            errorMessage = "Weak password"
                        default:
                            break
                        }
                    }
                    
                    self.presentErrorAlert(title: "Create Account Failed", message: errorMessage)
                    return
                }
                guard let result = result else {
                    self.presentErrorAlert(title: "Create Account Failed", message: "Something went wrong. Please try again later.")
                    return
                }
                let userId = result.user.uid
                let userData: [String: Any] = [
                    "id": userId,
                    "username": username
                ]
                Database.database().reference().child("users").child(userId).setValue(userData)
                Database.database().reference().child("usernames").child(username).setValue(userData)
                
                let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let homeVC = mainStoryboard.instantiateViewController(withIdentifier: "HomeViewController")
                let navVC = UINavigationController(rootViewController: homeVC)
                let window = UIApplication.shared.connectedScenes.flatMap {($0 as? UIWindowScene)?.windows ?? []}.first {$0.isKeyWindow}
                window?.rootViewController = navVC
            }

        }
    }
   
}

extension CreateAccountViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if URL.scheme == "chatappcreate" {
            performSegue(withIdentifier: "SignInSegue", sender: nil)
        }
        return false
    }
    
}

extension CreateAccountViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeTextField = nil
    }
}
