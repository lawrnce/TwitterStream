//
//  ViewController.swift
//  TwitterStream
//
//  Created by lola on 4/29/16.
//  Copyright © 2016 LawrenceTran. All rights reserved.
//

import UIKit
import SwiftyJSON

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
    
    // Tweet processing is handled on this queue
    var tweetQueue: dispatch_queue_t!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNotification()
        setupTwitterManager()
        setupSearchBar()
        setupFilterView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    /**
        MARK: - Selectors
     */
    func firstTweetOfType(notification: NSNotification) {
        
        // get tweet type
        let typeHash = (notification.object as! Int)
        
        let type = TweetType(rawValue: typeHash)
        
        // update UI
        self.filterView.setFilterButtonImageForFilterType(type!, forState: true)
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
        setupTweetQueue()
        
        // Testing
        self.twitterManager.createStreamConnectionForKeyword("anime")
    }
    
    /**
        Setup filter view. Initially accept all types.
     */
    private func setupFilterView() {
        self.filterView.delegate = self
    }
    
    /**
        Setup Notifications
     */
    private func setupNotification() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "firstTweetOfType:", name: kFIRST_TWEET_FOR_TYPE_NOTIFICATION, object: nil)
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
    func twitterManager(twitterManager: TwitterManager, didStreamTweet tweet: JSON) {
        
        // lazy load a tweets data structure
        if (self.tweets == nil) {
            self.tweets = TweetsModel()
            self.currentList = [Int]()
        }
        
        // Insert tweet
        dispatch_async(self.tweetQueue) { () -> Void in
            
            self.tweets.insertTweet(tweet, completion: { (filtered, key) -> () in
                
                // Current filter allows new tweet
                if (filtered == true) {
                    
                    // Append to current list
                    self.currentList.append(key!)
                    print(key!)
                }
            })
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
        
        // Ignore filter control if no tweets
        guard self.tweets != nil else {
            return
        }
        
        // Access tweets on tweet queue
        dispatch_async(self.tweetQueue) { () -> Void in
            
            // Ignore user action if type has no tweets
            guard self.tweets.countForType(type) != 0 else {
                return
            }
    
            // Toggle tweets filter
            self.tweets.toggleFilterForType(type)
            self.currentList = self.tweets.getFilteredTweets()
            
            let filterState = self.tweets.filterStateForType(type)
            
            // update ui
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                self.filterView.setFilterButtonImageForFilterType(type, forState: filterState)
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