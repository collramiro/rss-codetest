//
//  HomeViewController.swift
//  RSS-O-Matic
//
//  Created by Ramiro Coll Doñetz on 09/08/2019.
//  Copyright © 2019 Ramiro Coll Doñetz. All rights reserved.
//

import UIKit
import SVProgressHUD
import EmptyDataSet_Swift

class HomeViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    var feeds = [Feed]()

    // MARK: - App Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Feeds"
        
        //test code
        if let user = DataManager.shared().user {
            print("LOGGED IN")
            print(user.authToken)
        }
        
        //setup observer for successfully login/register
        NotificationCenter.default.addObserver(self, selector: #selector(shouldReloadFeeds(_:)), name: .shouldReloadFeeds, object: nil)
        
        setupUI()
        
        reloadFeeds()
    }
    
    private func setupUI() {
        setupEmptyDataSet()
    }
    
    @objc func shouldReloadFeeds(_ notification:Notification) {
      reloadFeeds()
    }
    
    // MARK: - Endpoint Connection
    private func reloadFeeds() {
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
    
    private func removeFeed(indexPath: IndexPath) {
        SVProgressHUD.show()
        
        let feed = feeds[indexPath.row]

        APIClient.removeFeed(feedId: feed.feedId) { (result) in
            switch result {
            case .success:
                SVProgressHUD.dismiss()
                self.feeds.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .fade)
                self.tableView.reloadEmptyDataSet()
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
        
        alert.addAction(UIAlertAction(title: "Logout", style: .destructive , handler:{ (UIAlertAction)in
            //logout user and go back to onboarding
            self.logout()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{ (UIAlertAction)in

        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func onEditPressed(_ sender: Any) {
        toggleEditing()
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

// MARK: - Tableview/Empty dataset Management
extension HomeViewController : UITableViewDelegate, UITableViewDataSource, EmptyDataSetSource, EmptyDataSetDelegate {
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
    
    @objc private func toggleEditing() {
        tableView.setEditing(!tableView.isEditing, animated: true) // Set opposite value of current editing status
        editButton.title = tableView.isEditing ? "Done" : "Edit" // Set title depending on the editing status
    }
    
    var emptyDataSetTitleString: NSAttributedString? {
        var attributes: [NSAttributedString.Key: Any] = [:]
        attributes[NSAttributedString.Key.font] = UIFont.systemFont(ofSize: 17.0, weight: .bold)
        attributes[NSAttributedString.Key.foregroundColor] = UIColor.darkText
        return NSAttributedString.init(string: "No feeds yet", attributes: attributes)
    }
    
    var emptyDataSetDetailString: NSAttributedString? {
        var attributes: [NSAttributedString.Key: Any] = [:]
        attributes[NSAttributedString.Key.font] = UIFont.systemFont(ofSize: 17.0)
        return NSAttributedString.init(string: "Subscribe to one of our RSS feeds to start receiving news.", attributes: attributes)
    }
    
    var emptyDataSetButtonString: NSAttributedString? {
        var attributes: [NSAttributedString.Key: Any] = [:]
        
        attributes[NSAttributedString.Key.font] = UIFont.systemFont(ofSize: 17.0)
        attributes[NSAttributedString.Key.foregroundColor] = self.view.tintColor
        return NSAttributedString.init(string: "Add Feed", attributes: attributes)
    }
    
    func setupEmptyDataSet() {
        //setup empty data set for tableview
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self

        tableView.emptyDataSetView { view in
            view.titleLabelString(self.emptyDataSetTitleString)
                .detailLabelString(self.emptyDataSetDetailString)
                .image(UIImage.init(named: "rssIcon"))
                .buttonTitle(self.emptyDataSetButtonString, for: .normal)
                .dataSetBackgroundColor(UIColor.white)
                .verticalSpace(30)
                .shouldFadeIn(true)
                .isTouchAllowed(true)
                .isScrollAllowed(true)
                .didTapDataButton {
                    self.performSegue(withIdentifier: "goToAddFeed", sender: nil)
            }
        }
    }
    
    func emptyDataSetWillAppear(_ scrollView: UIScrollView) {
        if tableView.isEditing {
            toggleEditing()
        }
        
        self.editButton.isEnabled = false
    }
    
    func emptyDataSetDidDisappear(_ scrollView: UIScrollView) {
        if tableView.isEditing {
            toggleEditing()
        }
        
        self.editButton.isEnabled = true
    }
}

extension Notification.Name {
    static let shouldReloadFeeds = Notification.Name("shouldReloadFeeds")
}
