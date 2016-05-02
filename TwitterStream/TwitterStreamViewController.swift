//
//  ViewController.swift
//  TwitterStream
//
//  Created by lola on 4/29/16.
//  Copyright © 2016 LawrenceTran. All rights reserved.
//

import UIKit

class TwitterStreamViewController: UIViewController {

    // Filter view
    @IBOutlet weak var filterView: FilterView!
    
    // Table view to display the streams
    @IBOutlet weak var tableView: UITableView!
    
    // Tweets data structure
    var tweets: TweetsModel!
    
    // Current list of tweet keys for user selection
    var currentList: [Int]!
    
    // Twitter Stream
    var twitterManager: TwitterManager!
    
    // Search bar
    var searchController: UISearchController!
    
    // Playback is initially false
    var playback: Bool = false
    
    // Boolean values of current filter
    var filter: (gif: Bool, text: Bool, video: Bool, photo: Bool)!
    
    // Tweet processing is handled on this queue
    var tweetQueue: dispatch_queue_t!
    
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
        self.twitterManager.createStreamConnectionForKeyword("anime")
    }
    
    /**
        Setup filter view. Initially accept all types.
     */
    private func setupFilterView() {
        self.filter = (true, true, true, true)
        self.filterView.delegate = self
    }
    
    /**
        Setup tweet processing queue. This is the queue were we add and filter tweets.
     */
    private func setupTweetQueue() {
        self.tweetQueue = dispatch_queue_create("com.lawrnce.tweetQueue", DISPATCH_QUEUE_SERIAL)
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
    
    /**
        On receiving a tweet. Process it in the background.
     */
    func twitterManager(twitterManager: TwitterManager, didStreamTweet tweet: [String: AnyObject]) {
        
        dispatch_async(self.tweetQueue) { () -> Void in
            print(tweet)
        }
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
    func filterView(filterView: FilterView, didToggleFilterForType type: TweetType) {
        
        // toggle filter
        switch (type) {
        case .Gif:
            self.filter!.gif = !self.filter!.gif
            self.filterView.setFilterButtonImageForFilterType(type, forState: self.filter!.gif)
        case .Text:
            self.filter!.text = !self.filter!.text
            self.filterView.setFilterButtonImageForFilterType(type, forState: self.filter!.text)
        case .Video:
            self.filter!.video = !self.filter!.video
            self.filterView.setFilterButtonImageForFilterType(type, forState: self.filter!.video)
        case .Photo:
            self.filter!.photo = !self.filter!.photo
            self.filterView.setFilterButtonImageForFilterType(type, forState: self.filter!.photo)
        }
        
        // get filtered tweets
        dispatch_async(self.tweetQueue) { () -> Void in
            
            self.currentList = self.tweets.filterTweets(self.filter)
            
            // update ui
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
            })
        }
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
                self.twitterManager.resumeStream()
            
            // Pause Stream
            } else {
                self.twitterManager.pauseStream()
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