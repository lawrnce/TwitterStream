//
//  ViewController.swift
//  TwitterStream
//
//  Created by lola on 4/29/16.
//  Copyright © 2016 LawrenceTran. All rights reserved.
//

import UIKit

enum TweetFilter {
    case Gif
    case Text
    case Video
    case Photo
}

class TwitterStreamViewController: UIViewController {

    // Filter view
    @IBOutlet weak var filterView: FilterView!
    
    // Table view to display the streams
    @IBOutlet weak var tableView: UITableView!
    
    // Twitter Stream
    var twitterManager: TwitterManager!
    
    // Search bar
    var searchController: UISearchController!
    
    // Array of tweets
    var tweets: [[String: AnyObject]]!
    
    // Playback is initially false
    var playback: Bool = false
    
    // Boolean values of current filter
    var filter: (gif: Bool, text: Bool, video: Bool, photo: Bool)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTwitterManager()
        setupSearchBar()
        setupFilterView()
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
        self.twitterManager.createStreamConnectionForKeyword("politics")
    }
    
    /**
        Setup filter view. Initially accept all types.
     */
    private func setupFilterView() {
        self.filter = (true, true, true, true)
        self.filterView.delegate = self
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
    Filter view delegate
 */
extension TwitterStreamViewController: FilterViewDelegate {
    
    /**
        Called when user toggles a filter.
     */
    func filterView(filterView: FilterView, didToggleFilter filter: TweetFilter) {
        
        // toggle filter
        switch (filter) {
            case .Gif:
                self.filter!.gif = !self.filter!.gif
                self.filterView.setFilterButtonImageForFilter(filter, forState: self.filter!.gif)
            case .Text:
                self.filter!.text = !self.filter!.text
                self.filterView.setFilterButtonImageForFilter(filter, forState: self.filter!.text)
            case .Video:
                self.filter!.video = !self.filter!.video
                self.filterView.setFilterButtonImageForFilter(filter, forState: self.filter!.video)
            case .Photo:
                self.filter!.photo = !self.filter!.photo
                self.filterView.setFilterButtonImageForFilter(filter, forState: self.filter!.photo)
        }
        
        // update filter view
        
        // update table view
    }
    
    /**
        Called when user toggles playback.
     */
    func didTogglePlayback() {
        
        // Playback can only be toggled if connected to stream
        if (self.twitterManager.isConnected == true) {
            
            self.playback = !self.playback
            self.filterView.setPlaybackButtonImageForState(self.playback)
            
            // Resume Stream
            if (self.playback == true) {
                
            
            // Pause Stream
            } else {
                
            }
        }
    }
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