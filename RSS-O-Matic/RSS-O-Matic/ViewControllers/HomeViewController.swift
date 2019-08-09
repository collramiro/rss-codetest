//
//  HomeViewController.swift
//  RSS-O-Matic
//
//  Created by Ramiro Coll Doñetz on 09/08/2019.
//  Copyright © 2019 Ramiro Coll Doñetz. All rights reserved.
//

import UIKit

class HomeViewController: BaseViewController {

    // MARK: - App Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if let user = DataManager.shared().user {
            print("LOGGED IN")
            print(user.authToken)
        }
    }
    
    // MARK: - Logout
    private func logout() {
        // Delete user data
        DataManager.shared().clearUser()
        
        // Navigate to onboarding
        guard let window = UIApplication.shared.keyWindow else {
            return
        }
        
        guard let rootViewController = window.rootViewController else {
            return
        }
        
        let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
        let vc = storyboard.instantiateInitialViewController()
        vc?.view.frame = rootViewController.view.frame
        vc?.view.layoutIfNeeded()
        
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
            window.rootViewController = vc
        }, completion: { completed in
            // maybe do something here
        })
    }
    
    // MARK: - Button Delegates
    @IBAction func onMoreOptionsPressed(_ sender: Any) {
        let alert = UIAlertController(title: "More", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Add Feed", style: .default , handler:{ (UIAlertAction)in

        }))
        
        alert.addAction(UIAlertAction(title: "Logout", style: .default , handler:{ (UIAlertAction)in
            //logout user and go back to onboarding
            self.logout()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{ (UIAlertAction)in

        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
