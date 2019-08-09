//
//  AuthViewController.swift
//  RSS-O-Matic
//
//  Created by Ramiro Coll Doñetz on 09/08/2019.
//  Copyright © 2019 Ramiro Coll Doñetz. All rights reserved.
//

import UIKit
import IHKeyboardAvoiding

class AuthViewController: BaseViewController {
    
    public enum AuthScreenState {
        case login
        case register
    }
    
    var state: AuthScreenState = .login
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var explanationLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
    // MARK: - App Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        // Setup keyboard avoiding
        KeyboardAvoiding.avoidingView = contentView
        
        if state == .login {
            explanationLabel.text = "Welcome back! Enter your credentials to login and start using this amazing app 😉"
            submitButton.setTitle("Login", for: .normal)
            
            usernameTextField.text = "ramiro_postman"
            passwordTextField.text = "testpassword"
        } else {
            explanationLabel.text = "Welcome! Enter your credentials to register and start using this amazing app 😉"
            submitButton.setTitle("Register", for: .normal)
        }
    }
    
    // MARK: - Endpoint Connection
    private func register(username: String, password: String) {
        APIClient.register(username: username, password: password) { result in
            switch result {
            case .success(let user):
                print("success register")
                self.onSuccessfulAuthentification(user: user)
            case .failure(let error):
                print(error.localizedDescription)
                //this can be improved with better parsing, but is good for now
                self.showErrorAlert(title: "Wrong Credentials", message: "Please enter a valid username and password.")
            }
        }
    }
    
    private func login(username: String, password: String) {
        APIClient.login(username: username, password: password) { result in
            switch result {
            case .success(let user):
                print("success login")
                self.onSuccessfulAuthentification(user: user)
            case .failure(let error):
                print(error.localizedDescription)
                //this can be improved with better parsing, but is good for now
                self.showErrorAlert(title: "Wrong Credentials", message: "Please check your username and password.")
            }
        }
    }
    
    private func onSuccessfulAuthentification(user: User) {
        DataManager.shared().saveUser(user: user)
        NotificationCenter.default.post(name: .didAuthenticateUser, object: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Button Delegates
    
    @IBAction func onClosePressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onSubmitPressed(_ sender: Any) {
        
        //better validation can be applied here (how many chars of specific regex)
        //a better practice is to move this to a different method
        guard let username = usernameTextField.text, username.isEmpty == false else {
            showErrorAlert(title: "Invalid Username", message: "Please enter a valid username.")
            return
        }
        
        guard let password = passwordTextField.text, password.isEmpty == false else {
            showErrorAlert(title: "Invalid Password", message: "Please enter a valid password.")
            return
        }
        
        switch state {
        case .register:
            register(username: username, password: password)
        case .login:
            login(username: username, password: password)
        }
    }
}

// MARK: - Textfield management
extension AuthViewController: UITextFieldDelegate {
    // These delegate methods can be used so that test fields that are hidden by the keyboard are shown when they are focused
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == usernameTextField {
            KeyboardAvoiding.avoidingView = contentView
        }
            
        else if textField == passwordTextField {
            KeyboardAvoiding.padding = 20
            KeyboardAvoiding.avoidingView = textField
            KeyboardAvoiding.padding = 0
        }
        return true
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameTextField {
            self.passwordTextField.becomeFirstResponder()
        }
        else if textField == passwordTextField {
            textField.resignFirstResponder()
        }
        return true
    }
}
