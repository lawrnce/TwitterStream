//
//  ViewController.swift
//  TwitterStream
//
//  Created by lola on 4/29/16.
//  Copyright © 2016 LawrenceTran. All rights reserved.
//

import UIKit
import AVFoundation
import SwiftyJSON
import Haneke

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
    
    // Image cache
    var imageCache: Cache<UIImage>!
    
    // Media cache
    var mediaCache: Cache<NSData>!
    
    // Search bar
    var searchController: UISearchController!
    
    // Playback is initially false
    var playback: Bool = false
    
    // Tweet processing is handled on this queue
    var tweetQueue: dispatch_queue_t!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCache()
        setupTableView()
        setupNotification()
        setupTwitterManager()
        setupSearchBar()
        setupFilterView()
        flushCache()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - Selectors
    
    /**
        Called when the first of a new tweet type is streamed.
    
        - Parameter notification: The notification containing the tweet type.
     */
    func firstTweetOfType(notification: NSNotification) {
        
        // get tweet type
        let typeHash = (notification.object as! Int)
        
        let type = TweetType(rawValue: typeHash)
        
        // update UI
        self.filterView.setFilterButtonImageForFilterType(type!, forState: true)
    }
    
   
    // MARK: - Data
     
    /**
        When a new keyword is being streamed. Flushes the cache.
     */
    private func flushCache() {
        self.imageCache.removeAll()
        self.mediaCache.removeAll()
    }
    
    // MARK: - Setup
     
    /**
        Setup cache
     */
    private func setupCache() {
        self.imageCache = Shared.imageCache
        self.mediaCache = Shared.dataCache
    }
    
    /**
        Setup Table View
     */
    private func setupTableView() {
        self.tableView.registerNib(UINib(nibName: "TweetTableViewCell", bundle: nil), forCellReuseIdentifier: kTweetTableViewCellReuseIdentifier)
    }
    
    /**
        Setup Twitter Manager
     */
    private func setupTwitterManager() {
        self.twitterManager = TwitterManager()
        self.twitterManager.delegate = self
        setupTweetQueue()
        
        // Testing
        self.twitterManager.createStreamConnectionForKeyword("gif")
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
    
    
    // MARK: - Animations
    
    /**
        Animates a new cell into table if user is scrolled near the top.
     */
    private func animateNewTweetIfNeeded() {
        
        // Do not scroll the table view is user is not near the top
        if(self.tableView.contentOffset.y > 20.0) {
            
            let beforeContentSize = self.tableView.contentSize
            self.tableView.reloadData()
            let afterContentSize = self.tableView.contentSize
            let afterContentOffset = self.tableView.contentOffset
            let newContentOffset = CGPointMake(afterContentOffset.x, afterContentOffset.y + afterContentSize.height - beforeContentSize.height)
            
            self.tableView.setContentOffset(newContentOffset, animated: false)
            
        // Animate if user is near the top
        } else {
            self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Fade)
        }
    }
    
    /**
        Set a player to loop for a gif.
     */
    private func loopVideo(videoPlayer: AVPlayer) {
        NSNotificationCenter.defaultCenter().addObserverForName(AVPlayerItemDidPlayToEndTimeNotification, object: nil, queue: nil) { notification in
            videoPlayer.seekToTime(kCMTimeZero)
            videoPlayer.play()
        }
    }
    
    // MARK: - Helpers
    
    /**
        Return the url for an animated gif.
    
        - Parameter data: The "media" entry in the tweet JSON.
        - Returns: A NSURL of the gif.
     */
    private func getGifUrlFromData(data: SwiftyJSON.JSON) -> NSURL? {
        
        // iterate through the json
        for (_, subJson) in data["media"] {
            
            // if type is gif
            if (subJson["type"] == "animated_gif") {
                return NSURL(string: subJson["url"].stringValue)
            }
        }
        
        return nil
    }
    
    /**
        Returns a url for a media type.
     
        - Parameter data: The tweet data.
        -
        - Returns: A NSURL of the media.
     */
    private func getUrlFromData(data: SwiftyJSON.JSON, forType type: TweetType) -> NSURL? {
        
        if (type == .Gif) {
            
            for (_, subJson) in data["media"] {
                
                // if type is gif
                if (subJson["type"] == "animated_gif") {
                    return NSURL(string: subJson["url"].stringValue)
                }
            }
            
        } else if (type == .Photo) {
            return NSURL(string: data["photos"].arrayValue.first!["url"].stringValue)
        }

        return nil
    }
}

// MARK: - Twitter Manager Delegate
// Handles all streaming releated notifications

extension TwitterStreamViewController: TwitterManagerDelegate {
    
    /**
        On receiving a tweet. Process it in the background.
     */
    func twitterManager(twitterManager: TwitterManager, didStreamTweet tweet: SwiftyJSON.JSON) {
        
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
                    
                    // Update table
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.currentList.insert(key!, atIndex: 0)
                        self.animateNewTweetIfNeeded()
                    })
                }
            })
        }
    }
}

// MARK: - Search Bar Delegate
// Processes search terms
extension TwitterStreamViewController: UISearchControllerDelegate, UISearchBarDelegate {
    

}


// MARK: - Filter view delegate
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
            let newList = self.tweets.getFilteredTweets()
            let filterState = self.tweets.filterStateForType(type)
            
            // update ui
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.currentList = newList
                self.filterView.setFilterButtonImageForFilterType(type, forState: filterState)
                self.tableView.reloadData()
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

// MARK: - Table View Data Source
extension TwitterStreamViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard self.currentList != nil else {
            return 0
        }
        
        return self.currentList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(kTweetTableViewCellReuseIdentifier, forIndexPath: indexPath) as! TweetTableViewCell
        
        // Get tweet data from the TweetsModel
        let tweet: (data: SwiftyJSON.JSON, type: TweetType) = self.tweets.tweetForKey(self.currentList[indexPath.row])
        
        // Fetch profile image
        // Haneke will cache it for later
        cell.profileImageView.hnk_setImageFromURL(NSURL(string: tweet.data["profile_image_url"].stringValue)!)
        
        // Set screen name
        cell.screenNameLabel.text = tweet.data["screen_name"].stringValue
        
        // Set text
        cell.textView.text = tweet.data["text"].stringValue
        
        // Set media for type
        switch(tweet.type) {
        case .Gif:
            
            // Get gif url
            if let url = getGifUrlFromData(tweet.data) {
                
                // Fetch and cache data
                self.mediaCache.fetch(URL: url)
                    
                    // Downloaded
                    .onSuccess({ (data) -> () in
                        
                        // url of cached data
                        let path = NSURL(string: DiskCache.basePath())!.URLByAppendingPathComponent("shared-data/original")
                        let cached = DiskCache(path: path.absoluteString).pathForKey(url.absoluteString)
                        let file = NSURL(fileURLWithPath: cached)
                        
                        // setup video player
                        cell.videoItem = AVPlayerItem(URL: file)
                        cell.videoPlayer = AVPlayer(playerItem: cell.videoItem)
                        cell.avLayer = AVPlayerLayer(player: cell.videoPlayer)
                        cell.avLayer.frame = cell.mediaView.frame
                        cell.contentView.layer.addSublayer(cell.avLayer)
                        
                        // play and loop
                        cell.videoPlayer.play()
                        self.loopVideo(cell.videoPlayer)
                    })
                    // Error
                    .onFailure({ (error) -> () in
                    
                    })
            }
        case .Text:
            break
        case .Video:
//            cell.backgroundColor = UIColor.purpleColor()
            break
        case .Photo:
            cell.photoImageView = UIImageView(frame: cell.mediaView.frame)
            cell.photoImageView.contentMode = .ScaleAspectFit
            cell.contentView.addSubview(cell.photoImageView)
            cell.photoImageView.hnk_setImageFromURL(NSURL(string: tweet.data["photos"].arrayValue.first!["url"].stringValue)!)
        }
    
        return cell
    }
}

// MARK: - Table View Delegate
extension TwitterStreamViewController: UITableViewDelegate {
    
    /**
        Set the cell's height
     */
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        // Get type
        let type = self.tweets.typeForKey(self.currentList[indexPath.row])
        
        // Return cell height
        if (type == .Text) {
            return kTEXT_TWEET_BASE_HEIGHT
        } else {
            return kMEDIA_TWEET_BASE_HEIGHT
        }
    }
}