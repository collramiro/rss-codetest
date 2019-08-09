//
//  AddFeedViewController.swift
//  RSS-O-Matic
//
//  Created by Ramiro Coll Doñetz on 09/08/2019.
//  Copyright © 2019 Ramiro Coll Doñetz. All rights reserved.
//

import UIKit
import SVProgressHUD

class AddFeedViewController: BaseViewController {

    let rssFeeds: [[String:String]] = [["BBC world news":"http://feeds.bbci.co.uk/news/world/rss.xml"],
                                    ["CBN world news":"http://www.cbn.com/cbnnews/world/feed/"],
                                    ["Reuters Entertainment news":"http://feeds.reuters.com/reuters/entertainment"],
                                    ["Reuters Arts news":"http://feeds.reuters.com/news/artsculture"],
                                    ["BBC Asia news":"http://feeds.bbci.co.uk/news/world/asia/rss.xml"],
                                    ["BBC LATAM news":"http://feeds.bbci.co.uk/news/world/latin_america/rss.xml"],
                                    ["BBC UK news":"http://feeds.bbci.co.uk/news/rss.xml"],
                                    ["CBN US news":"http://www.cbn.com/cbnnews/us/feed/"],
                                    ["Reuters US news":"http://feeds.reuters.com/Reuters/domesticNews"],
                                    ["Reuters Environment news":"http://feeds.reuters.com/reuters/environment"],
                                    ["BBC technology news":"http://feeds.bbci.co.uk/news/technology/rss.xml"],
                                    ["BBC business news":"http://feeds.bbci.co.uk/news/business/rss.xml"]]

    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - App Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: - Endpoint Connection
    private func subscribeFeed(feedUrl: String) {
        SVProgressHUD.show()
        
        APIClient.subscribeFeed(feedUrl: feedUrl) { (result) in
            switch result {
            case .success:
                SVProgressHUD.dismiss()
                self.navigateToHome()
            case .failure(let error):
                print(error.localizedDescription)
                SVProgressHUD.dismiss()
                self.showErrorAlert(title: "Error", message: "Something when wrong trying to add the feed to your list. Maybe you're already registered.")
            }
        }
    }
    
    // MARK: - Navigation
    private func navigateToHome() {
        NotificationCenter.default.post(name: .shouldReloadFeeds, object: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
}

// MARK: - Tableview management
extension AddFeedViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell") as UITableViewCell?
        
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        }
        
        let feedTitle = rssFeeds[indexPath.row].keys.first
        cell!.textLabel?.text = feedTitle
        return cell!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rssFeeds.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let feedUrl = rssFeeds[indexPath.row].values.first!
        subscribeFeed(feedUrl: feedUrl)
    }
}
