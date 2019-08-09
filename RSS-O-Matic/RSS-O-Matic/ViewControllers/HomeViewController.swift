//
//  HomeViewController.swift
//  RSS-O-Matic
//
//  Created by Ramiro Coll Doñetz on 09/08/2019.
//  Copyright © 2019 Ramiro Coll Doñetz. All rights reserved.
//

import UIKit
import SVProgressHUD

class HomeViewController: BaseViewController {
    
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
        
        setupUI()
    }
    
    private func setupUI() {
        let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(toggleEditing)) // create a bat button
        navigationItem.leftBarButtonItem = editButton // assign button
    }
    
    @objc private func toggleEditing() {
        tableView.setEditing(!tableView.isEditing, animated: true) // Set opposite value of current editing status
        navigationItem.leftBarButtonItem?.title = tableView.isEditing ? "Done" : "Edit" // Set title depending on the editing status
    }
    
    // MARK: - Endpoint Connection
    private func removeFeed(indexPath: IndexPath) {
        SVProgressHUD.show()
        
        let feed = feeds[indexPath.row]

        APIClient.removeFeed(feedId: feed.feedId) { (result) in
            switch result {
            case .success:
                SVProgressHUD.dismiss()
                self.feeds.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .fade)
            case .failure(let error):
                print(error.localizedDescription)
                SVProgressHUD.dismiss()
                self.showErrorAlert(title: "Error", message: "Something when wrong trying to remove the feed from your list. Please try again.")
            }
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
            self.performSegue(withIdentifier: "goToAddFeed", sender: self)
        }))
        
        alert.addAction(UIAlertAction(title: "Edit Feeds", style: .default , handler:{ (UIAlertAction)in
            self.performSegue(withIdentifier: "goToAddFeed", sender: self)
        }))
        
        alert.addAction(UIAlertAction(title: "Logout", style: .destructive , handler:{ (UIAlertAction)in
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

// MARK: - Tableview Management
extension HomeViewController : UITableViewDelegate, UITableViewDataSource {
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
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            removeFeed(indexPath: indexPath)
        }
    }
}
