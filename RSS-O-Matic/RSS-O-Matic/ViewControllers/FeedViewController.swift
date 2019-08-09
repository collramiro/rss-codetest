//
//  FeedViewController.swift
//  RSS-O-Matic
//
//  Created by Ramiro Coll Doñetz on 09/08/2019.
//  Copyright © 2019 Ramiro Coll Doñetz. All rights reserved.
//

import UIKit

class FeedViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var feed : Feed!
    var articles = [Article]()

    // MARK: - App Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = feed.title
        
        APIClient.getArticles(feedId: feed.feedId) { (result) in
            switch result {
            case .success(let articleList):
                self.articles = articleList.articles
                self.tableView.reloadData()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Button Delegates
  
}

// MARK: - Tableview management
extension FeedViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell") as UITableViewCell?
        
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        }
        
        cell!.textLabel?.text = articles[indexPath.row].title
        return cell!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let article = articles[indexPath.row]
        let webView = WebViewController.createWebViewContainer(url: URL.init(string: article.url)!)
        webView.modalPresentationStyle = .overCurrentContext
        self.present(webView, animated: false, completion: nil)
    }
}
