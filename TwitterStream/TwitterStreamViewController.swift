//
//  ViewController.swift
//  TwitterStream
//
//  Created by lola on 4/29/16.
//  Copyright © 2016 LawrenceTran. All rights reserved.
//

import UIKit

class TwitterStreamViewController: UIViewController {

    // Table view to display the streams
    @IBOutlet weak var tableView: UITableView!
    
    // Twitter Stream
    var twitterManager: TwitterManager!
    
    // Search bar
    var searchController: UISearchController!
    
    // Array
    var tweets: [[String: AnyObject]]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTwitterManager()
        setupSearchBar()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
        MARK: - Setup
     */
    
    /**
        Setup Twitter Manager
     */
    private func setupTwitterManager() {
        self.twitterManager = TwitterManager()
        self.twitterManager.delegate = self
        
        // Testing
        self.twitterManager.createStreamConnectionForKeyword("video")
    }
     
    /**
        Setup search bar with white tint.
     */
    private func setupSearchBar() {
        self.searchController = UISearchController(searchResultsController:  nil)
        self.searchController.delegate = self
        self.searchController.searchBar.delegate = self
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.dimsBackgroundDuringPresentation = true
        self.searchController.searchBar.tintColor = UIColor.whiteColor()
        self.searchController.searchBar.placeholder = "Search Twitter"
        self.navigationItem.titleView = searchController.searchBar
        self.definesPresentationContext = true
    }
    
}

/**
    Twitter Manager Delegate - Handles all streaming releated notifications
 */
extension TwitterStreamViewController: TwitterManagerDelegate {
    
    func twitterManager(twitterManager: TwitterManager, didStreamTweet tweet: [String: AnyObject]) {
        print(tweet)
    }
}

/**
    Search Bar Delegate - Processes search terms
 */
extension TwitterStreamViewController: UISearchControllerDelegate, UISearchBarDelegate {
    

}

/**
    Table View Data Source
 */
extension TwitterStreamViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}

/**
    Table View Delegate
 */
extension TwitterStreamViewController: UITableViewDelegate {
    
}