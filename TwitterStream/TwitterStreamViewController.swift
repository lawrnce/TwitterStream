//
//  ViewController.swift
//  TwitterStream
//
//  Created by lola on 4/29/16.
//  Copyright © 2016 LawrenceTran. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
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
    var playback: Bool = true
    
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
    
    // MARK: - Key Value Observing
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        // Gif player
        if (object?.classForCoder == AVPlayer.self && keyPath == "status") {
            if ((object as! AVPlayer).status == .ReadyToPlay) {
                (object as! AVPlayer).play()
            }
        }
    }
    
    // MARK: - Selectors
    
    /**
        Plays the selected video. The button's tag matches the tweet's key.
     */
    func playVideo(sender: UIButton) {
        let videoViewController = VideoPlayerViewController()
        videoViewController.url = self.tweets.mediaUrlForTweet(sender.tag)
        self.presentViewController(videoViewController, animated: false, completion: nil)
    }
    
    // MARK: - Notifications
    
    /**
        Setup Notifications
    */
    private func setupNotification() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "firstTweetOfType:", name: kFIRST_TWEET_FOR_TYPE_NOTIFICATION, object: nil)
    }
    
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
    
    /**
        AV Player notifications
     */
    private func loopVideoPlayer(videoPlayer: AVPlayer) {
        NSNotificationCenter.defaultCenter().addObserverForName(AVPlayerItemDidPlayToEndTimeNotification, object: videoPlayer.currentItem, queue: nil) { notification in
            videoPlayer.seekToTime(kCMTimeZero)
            videoPlayer.play()
        }
    }
    
   
    // MARK: - Data
    
    /**
        Restarts the stream with a new term.
     */
    private func newStreamWithKeyword(keyword: String) {
        flushCache()
        self.tweets = nil
        self.currentList = nil
        self.playback = true
        self.filterView.resetUIState()
        self.tableView.reloadData()
        self.twitterManager.createConnectionWithKeyword(keyword)
    }
    
    /**
        Returns the file url of an item in the cache.
     
        - Parameter key: The key for the item in the cache.
        - Returns: The file url of the cached item.
     */
    private func getUrlForCachedKey(key: String) -> NSURL {
        let path = NSURL(string: DiskCache.basePath())!.URLByAppendingPathComponent("shared-data/original")
        let cached = DiskCache(path: path.absoluteString).pathForKey(key)
        return NSURL(fileURLWithPath: cached)
    }
    
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
    }
    
    /**
        Setup filter view. Initially accept all types.
     */
    private func setupFilterView() {
        self.filterView.delegate = self
        self.filterView.resetUIState()
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
        self.searchController.searchBar.placeholder = "Search Twitter"
        self.navigationItem.titleView = searchController.searchBar
        self.definesPresentationContext = true
        
        // Set cancel button color
        self.searchController.searchBar.tintColor = UIColor.whiteColor()
        
        // Set cursor color
        self.searchController.searchBar.subviews[0].subviews.flatMap(){ $0 as? UITextField }.first?.tintColor = UIColor.blueColor()
    }
    
    // MARK: - Animations
    
    /**
        Animates a new cell into table if user is scrolled near the top.
     */
    private func animateNewTweetIfNeededForType(type: TweetType) {
        
        // Do not scroll the table view is user is not near the top
        if(self.tableView.contentOffset.y > 20.0) {
            
            // Get table view offset
            var tableViewOffset = self.tableView.contentOffset
            
            // Get off set for new cells
            tableViewOffset.y += (type == .Text) ? kTEXT_TWEET_BASE_HEIGHT : kMEDIA_TWEET_BASE_HEIGHT
            
            // Turn off animations when updating
            UIView.setAnimationsEnabled(false)
            
            // Add cell to table
            self.tableView.beginUpdates()
            self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .None)
            
            self.tableView.endUpdates()
            
            // Resume animations
            UIView.setAnimationsEnabled(true)
            
            self.tableView.setContentOffset(tableViewOffset, animated: false)
            
        // Animate if user is near the top
        } else {
            if (self.currentList != nil) {
                
                self.tableView.beginUpdates()
                self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Fade)
                self.tableView.endUpdates()
                
                // Sometimes Gifs will not play initially without reload
                if (type == .Gif) {
                    self.tableView.reloadData()
                }
            }
        }
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
            
            self.tweets.insertTweet(tweet, completion: { (filtered, key, type) -> () in
                
                // Current filter allows new tweet
                if (filtered == true) {
                    
                    // Update table
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.currentList.insert(key!, atIndex: 0)
                        self.animateNewTweetIfNeededForType(type!)
                        
                        // Update filter UI if needed
                        if (self.filterView.playbackButton.hidden == true) {
                            self.filterView.playbackButton.hidden = false
                            self.filterView.setPlaybackButtonImageForState(true)
                            self.filterView.activityIndicator.stopAnimating()
                        }
                    })
                }
            })
        }
    }
    
    /**
        Handle errors
     */
    func twitterManager(twitterManager: TwitterManager, failedWithErrorMessage error: String) {
        
        // Handle errors
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.filterView.activityIndicator.stopAnimating()
            
            // Alert UI
            if (error == kTWITTER_ACCESS_DENIED) {
                let alert = UIAlertController(title: "Access Denied", message: kTWITTER_ACCESS_DENIED, preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .Cancel, handler: { (action) -> Void in
                }))
                self.presentViewController(alert, animated: true, completion: nil)
            } else if (error == kNO_TWITTER_ACCOUNT){
                let alert = UIAlertController(title: "No Twitter Account Detected", message: kNO_TWITTER_ACCOUNT, preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .Cancel, handler: { (action) -> Void in
                }))
                self.presentViewController(alert, animated: true, completion: nil)
            } else if (error == kCONNECTION_ERROR) {
                print(error)
            }
        })
    }
    
    /**
        Stream reconnected after error
     */
    func reconnectedToStream() {
        print("Stream Reconnected")
    }
}

// MARK: - Search Bar Delegate
// Processes search terms
extension TwitterStreamViewController: UISearchControllerDelegate, UISearchBarDelegate {
    
    /**
        Take search term as "track" in HTTP stream.
     */
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        let searchTerm = searchBar.text!
        self.searchController.searchBar.placeholder = "\"" + searchTerm + "\""
        self.searchController.active = false
        self.filterView.activityIndicator.startAnimating()
        newStreamWithKeyword(searchTerm)
    }
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
            let newList = self.tweets.filteredTweets()
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
        
        self.playback = !self.playback
        self.filterView.setPlaybackButtonImageForState(self.playback)
            
        // Resume Stream
        if (self.playback == true) {
            self.twitterManager.resumeStream()
                
            // Animate activity indicator until stream reconnects
            self.filterView.playbackButton.hidden = true
            self.filterView.activityIndicator.startAnimating()
            
        // Pause Stream
        } else {
            self.twitterManager.pauseStream()
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
        
        // get key
        let key = self.currentList[indexPath.row]
        
        // Get tweet data from the TweetsModel
        let tweet: (data: SwiftyJSON.JSON, type: TweetType) = self.tweets.tweetForKey(key)
        
        // Set cell tag as tweet key
        cell.tag = key
        
        // Fetch profile image
        // Haneke will cache it for later
        cell.profileImageView.hnk_setImageFromURL(NSURL(string: tweet.data["profile_image_url"].stringValue)!)
        
        // Set screen name
        cell.screenNameLabel.text = tweet.data["screen_name"].stringValue
        
        // Set text
        cell.textView.text = tweet.data["text"].stringValue
        cell.textView.sizeToFit()
        
        // Set media for type
        switch(tweet.type) {
        case .Gif:
            
            // Get gif url
            if let gifURL = self.tweets.mediaUrlForTweet(key) {
                
                cell.mediaView.hidden = false
                
                // Fetch and cache data
                self.mediaCache.fetch(URL: gifURL)
                    
                    // Downloaded
                    .onSuccess({ (data) -> () in
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                           
                            // Sometimes gifs will not be removed in reuse if gifs come in too fast
                            // Force a refresh
                            cell.clearMediaView()
                            
                            // Get file url
                            let file = self.getUrlForCachedKey(gifURL.absoluteString)
                      
                            // Create gif view
                            let gifView = GifView(frame: cell.mediaView.bounds)
                            gifView.gifURL = file
                            cell.mediaView.addSubview(gifView)
                            
                            // Set KVO and Notification
                            gifView.player.addObserver(self, forKeyPath: "status", options: .New, context: nil)
                            self.loopVideoPlayer(gifView.player)
                        })
                    })
                
                    .onFailure({ (error) -> () in
                        print("GIF Failure: ", error)
                    })
            }
            
        case .Text:
            
            // Adjust cell for text only
            cell.activityIndicatorView.stopAnimating()
            cell.mediaView.hidden = true
            
        case .Video:

            // Get thumbnail
            if let thumbnailURL = self.tweets.imageUrlForTweet(key) {
   
                cell.mediaView.hidden = false
                
                // Fetch thumbnail
                self.imageCache.fetch(URL: thumbnailURL)
                    .onSuccess({ (image) -> () in
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                            // Set thumbnail image
                            let imageView = UIImageView(frame: cell.mediaView.bounds)
                            imageView.contentMode = .ScaleAspectFit
                            imageView.image = image
                            cell.mediaView.addSubview(imageView)
                            cell.activityIndicatorView.stopAnimating()
                        
                            // Set play button
                            let playButton = UIButton(frame: CGRect(x: 0, y: 0, width: 60.0, height: 60.0))
                            playButton.center = imageView.center
                            playButton.tag = key
                            playButton.setImage(UIImage(named: "VideoPlayButton"), forState: .Normal)
                            playButton.addTarget(self, action: Selector("playVideo:"), forControlEvents: .TouchUpInside)
                            cell.mediaView.addSubview(playButton)
                        })
                    })
            }
            
        case .Photo:
            
            // Get image
            if let imageURL = self.tweets.imageUrlForTweet(key) {
                
                // Adjust cell view
                cell.mediaView.hidden = false
                
                // Fetch image
                self.imageCache.fetch(URL: imageURL)
                    .onSuccess({ (image) -> () in
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                            // Set image
                            let imageView = UIImageView(frame: cell.mediaView.bounds)
                            imageView.contentMode = .ScaleAspectFit
                            imageView.image = image
                            cell.mediaView.addSubview(imageView)
                            cell.activityIndicatorView.stopAnimating()
                        
                        })
                    })
            }
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