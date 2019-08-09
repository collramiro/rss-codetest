//
//  BaseViewController.swift
//  RSS-O-Matic
//
//  Created by Ramiro Coll Doñetz on 09/08/2019.
//  Copyright © 2019 Ramiro Coll Doñetz. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    func showErrorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Got it!", style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }

}
