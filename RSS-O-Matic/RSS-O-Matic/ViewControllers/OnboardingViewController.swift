//
//  OnboardingViewController.swift
//  RSS-O-Matic
//
//  Created by Ramiro Coll Doñetz on 09/08/2019.
//  Copyright © 2019 Ramiro Coll Doñetz. All rights reserved.
//

import UIKit

class OnboardingViewController: BaseViewController {
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    
    // MARK: - App Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setup observer for successfully login/register
        NotificationCenter.default.addObserver(self, selector: #selector(onDidAuthenticateUser(_:)), name: .didAuthenticateUser, object: nil)
    }
    
    @objc func onDidAuthenticateUser(_ notification:Notification) {
        // Navigate to home        
        guard let window = UIApplication.shared.keyWindow else {
            return
        }
        
        guard let rootViewController = window.rootViewController else {
            return
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateInitialViewController()
        vc?.view.frame = rootViewController.view.frame
        vc?.view.layoutIfNeeded()
        
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
            window.rootViewController = vc
        }, completion: { completed in
            // maybe do something here
        })
    }
    
    private func showAuthScreen(authState: AuthViewController.AuthScreenState) {
        let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
        let authViewController = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as! AuthViewController
        authViewController.state = authState
        self.present(authViewController, animated: true, completion: nil)

    }

    // MARK: - Button Delegates
    @IBAction func onLoginPressed(_ sender: Any) {
        showAuthScreen(authState: .login)
    }
    
    @IBAction func onRegisterPressed(_ sender: Any) {
        showAuthScreen(authState: .register)
    }
}

extension Notification.Name {
    static let didAuthenticateUser = Notification.Name("didAuthenticateUser")
}

