//
//  Extension+UIViewController.swift
//  ChatApp
//
//  Created by Mac on 02/04/2025.
//

import Foundation
import UIKit

extension UIViewController {
    func presentErrorAlert (title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        present(alert, animated: true)
    }
}
