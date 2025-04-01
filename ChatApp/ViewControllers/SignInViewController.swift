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

    override func viewDidLoad() {
        super.viewDidLoad()
        containerView.clipsToBounds = true
        containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        let attributedString = NSMutableAttributedString(string: "Don't have an account? Create an account here.", attributes: [.font: Font.caption])
        attributedString.addAttribute(.link, value: "chatapp://createAccount", range: (attributedString.string as NSString).range(of:"Create an account here."))
        createAccountTextView.attributedText = attributedString
        createAccountTextView.linkTextAttributes = [.foregroundColor: UIColor.secondary, .font: Font.linkLabel]
        createAccountTextView.delegate = self
        createAccountTextView.isScrollEnabled = false
        createAccountTextView.textAlignment = .center
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        containerView.layer.cornerRadius = 20
    }

    @IBAction func signinButtonTapped(_ sender: Any) {
        
    }
}

extension SignInViewController: UITextViewDelegate {
    private func textView(_ textView: UITextView, shouldInteracWith URL: URL, in characterRange: NSRange, interaction: UITextInteraction) -> Bool {
        if URL.scheme == "chatapp" {
            performSegue(withIdentifier: "CreateAccountSegue", sender: nil)
        }
            return false
    }
}
