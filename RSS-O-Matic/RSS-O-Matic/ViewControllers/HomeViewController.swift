//
//  HomeViewController.swift
//  RSS-O-Matic
//
//  Created by Ramiro Coll Doñetz on 09/08/2019.
//  Copyright © 2019 Ramiro Coll Doñetz. All rights reserved.
//

import UIKit

class HomeViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var feeds = [Feed]()

    // MARK: - App Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Feeds"
        if let user = DataManager.shared().user {
            print("LOGGED IN")
            print(user.authToken)
        }
        
        APIClient.getFeeds { (result) in
            switch result {
            case .success(let feeds):
                self.feeds = feeds
                self.tableView.reloadData()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell") as UITableViewCell?
        
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        }
        
        cell!.textLabel?.text = feeds[indexPath.row].title
        return cell!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feeds.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let feed = feeds[indexPath.row]
        performSegue(withIdentifier: "goToFeed", sender: feed)
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
            self.performSegue(withIdentifier: "goToAddFeed", sender: self)
        }))
        
        alert.addAction(UIAlertAction(title: "Logout", style: .default , handler:{ (UIAlertAction)in
            //logout user and go back to onboarding
            self.logout()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{ (UIAlertAction)in

        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is FeedViewController
        {
            let vc = segue.destination as? FeedViewController
            if let feed = sender as? Feed {
                vc?.feed = feed
            }
        }
    }
}
