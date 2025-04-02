//
//  SignInViewController.swift
//  ChatApp
//
//  Created by mac on 1/4/2025.
//

import UIKit

class SignInViewController: UIViewController {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var createAccountTextView: UITextView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    var activeTextField: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        containerView.clipsToBounds = true
        containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        let attributedString = NSMutableAttributedString(string: "Don't have an account? Create an account here.", attributes: [.font: Font.caption])
        attributedString.addAttribute(.link, value: "chatappsignin://signinAccount", range: (attributedString.string as NSString).range(of: "Create an account here."))
        createAccountTextView.attributedText = attributedString
        createAccountTextView.linkTextAttributes = [.foregroundColor: UIColor.secondary, .font: Font.linkLabel]
        createAccountTextView.delegate = self
        createAccountTextView.isScrollEnabled = false
        createAccountTextView.textAlignment = .center
        createAccountTextView.isEditable = false
        emailTextField.delegate = self
        passwordTextField.delegate = self
        registerKeyboardNotification()
        let backgroundTap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(backgroundTap)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        containerView.layer.cornerRadius = 20
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        registerKeyboardNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
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
    
    @objc func keyboardWillShow(notification: NSNotification){
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        
        let keyboardOffset = view.convert(keyboardFrame.cgRectValue, from: nil).size.height
        let totalOffset = activeTextField == nil ? keyboardOffset : keyboardOffset + activeTextField!.frame.height
        scrollView.contentInset.bottom = totalOffset
    }
    
    @objc func keyboardWillHide(notification: NSNotification){
        scrollView.contentInset.bottom = 0
    }
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }

    @IBAction func signinButtonTapped(_ sender: Any) {
        
    }
}

extension SignInViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if URL.scheme == "chatappsignin" {
            performSegue(withIdentifier: "CreateAccountSegue", sender: nil)
        }
        return false
    }
    
}

extension SignInViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeTextField = nil
    }
}
