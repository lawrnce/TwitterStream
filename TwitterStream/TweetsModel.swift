//
//  TweetsModel.swift
//  TwitterStream
//
//  Created by lola on 5/1/16.
//  Copyright © 2016 LawrenceTran. All rights reserved.
//

import Foundation
import SwiftyJSON

enum TweetType: Int {
    case Gif
    case Text
    case Video
    case Photo
}

typealias TweetFilter = (gif: Bool, text: Bool, video: Bool, photo: Bool)

/**
    Data structure to store tweets and allow for fast filtering.
 */
class TweetsModel: NSObject {

    // Map each tweet to an integer string key.
    private var tweetHash: [Int: (data: JSON, type: TweetType)]!
    
    // List of gif tweets
    private var gifList: [Int]!
    
    // List of text tweets
    private var textList: [Int]!
    
    // List of video tweets
    private var videoList: [Int]!
    
    // List of photo tweets
    private var photoList: [Int]!
    
    // Current tweet filter
    private var filter: TweetFilter!
    
    override init() {
        super.init()
        self.tweetHash = [Int: (data: JSON, type: TweetType)]()
        self.textList = [Int]()
        self.gifList = [Int]()
        self.videoList = [Int]()
        self.photoList = [Int]()
        self.filter = (true, true, true, true)
    }
    
    // MARK: - Methods
    
    /**
        Returns the tweet data for a key.
     
        - Parameter key: A tweet's key.
        - Returns: A tuple containing a JSON of the data and its type.
     */
    func tweetForKey(key: Int) -> (data: JSON, type: TweetType) {
        return (self.tweetHash?[key])!
    }
    
    /**
        Returns the tweet type for a key.
     
        - Parameter key: A tweet's key.
        - Returns: A tweet type.
     */
    func typeForKey(key: Int) -> TweetType {
        return (self.tweetHash?[key])!.type
    }
    
    /**
        Returns the number of tweets for given type.
        
        - Parameter type: A tweet type.
        - Returns: The count of tweets for type.
     */
    func countForType(type: TweetType) -> Int {
        switch(type) {
        case .Gif:
            return self.gifList.count
        case .Text:
            return self.textList.count
        case .Video:
            return self.videoList.count
        case .Photo:
            return self.photoList.count
        }
    }
    
    /**
        Toggles the filter for a tweet type.
     
        - Parameter type: A tweet type.
     */
    func toggleFilterForType(type: TweetType) {
        switch(type) {
        case .Gif:
            self.filter.gif = !self.filter.gif
        case .Text:
            self.filter.text = !self.filter.text
        case .Video:
            self.filter.video = !self.filter.video
        case .Photo:
            self.filter.photo = !self.filter.photo
        }
    }
    
    /**
        Returns the filter state for a tweet type.
     
        - Parameter type: A tweet type.
        - Returns: A Boolean represting the filter state for type.
     */
    func filterStateForType(type: TweetType) -> Bool {
        switch(type) {
        case .Gif:
            return self.filter.gif
        case .Text:
            return self.filter.text
        case .Video:
            return self.filter.video
        case .Photo:
            return self.filter.photo
        }
    }
    
    /**
        Add tweet to hash and append it to its type list. If the new tweet
        falls under the current filter, pass the key to the caller.
     
        - Parameter tweet: The tweet to be inserted.
        - Parameter completion: The block to be executed after the tweet is inserted.
                                If the current filter allows the new tweet, the key is 
                                passed to the block.
     */
    func insertTweet(tweet: JSON, completion: (filtered: Bool, key: Int?, type: TweetType?) -> ()) {
        
        // Get tweet type
        let type = getTypeForTweet(tweet)
        
        // Get next key for hash
        let key = self.tweetHash.count
        
        // Set tweet hash and type
        self.tweetHash[key] = (tweet, type)
        
        // Append key to type list.
        // If first tweet for type, turn on filter UI.
        switch (type) {
        case .Text:
            if (self.textList.count == 0) {
                turnOnFilterButtonForTweetType(.Text)
            }
            self.textList.append(key)
        case .Gif:
            if (self.gifList.count == 0) {
                turnOnFilterButtonForTweetType(.Gif)
            }
            self.gifList.append(key)
        case .Video:
            if (self.videoList.count == 0) {
                turnOnFilterButtonForTweetType(.Video)
            }
            self.videoList.append(key)
        case .Photo:
            if (self.photoList.count == 0) {
                turnOnFilterButtonForTweetType(.Photo)
            }
            self.photoList.append(key)
        }
        
        // Determine if new tweet falls within current filter
        // If so pass the key to completion handler
        if (filterStateForType(type) == true) {
            completion(filtered: true, key: key, type: type)
        }
    }
    
    /**
        Return a filtered list of keys.
    
        - Parameter filter: The set of booleans representing which filters are active.
        - Returns: An array of keys for the filtered tweets.
     */
    func getFilteredTweets() -> [Int] {
        
        var keys = [Int]()
        
        // filter gif tweets
        if (self.filter.gif == true) {
            keys += self.gifList
        }
        
        // filter text tweets
        if (self.filter.text == true) {
            keys += self.textList
        }
        
        // filter video tweets
        if (self.filter.video == true) {
            keys += self.videoList
        }
        
        // filter photo tweets
        if (self.filter.photo == true) {
            keys += self.photoList
        }
        
        // order keys
        keys.sortInPlace({ $0 > $1 })
        
        return keys
    }
    
    /**
        Returns an image or a thumbnail image (depending tweet type)
        for a tweet.
        
        - Parameter key: The primary key of the tweet.
        - Returns: The image url. Nil if Tweet has no images
     */
    func getImageUrlForTweet(key: Int) -> NSURL? {
        
        let tweet = (self.tweetHash?[key])!
        
        switch(tweet.type) {
        case .Gif:
            return nil
        case .Text:
            return nil
            
        // Get the thumbnail image
        case .Video:
            for (_, subJson) in tweet.data["media"] {
                if (subJson["type"] == "video") {
                    return NSURL(string: subJson["thumbnail_url"].stringValue)!
                }
            }
        
        // Get image url
        case .Photo:
             return NSURL(string: tweet.data["photos"].arrayValue.first!["url"].stringValue)!
        }
    
        return nil
    }
    
    /**
        Returns the media url for a tweet.
     
        - Parameter key: The primary key of the tweet.
        - Returns: The media url. Nil if Tweet has no media
     */
    func getMediaUrlForTweet(key: Int) -> NSURL? {
        
        let tweet = (self.tweetHash?[key])!
        
        switch(tweet.type) {
        
        // Get gif url
        case .Gif:
            for (_, subJson) in tweet.data["media"] {
                
                // if type is gif
                if (subJson["type"] == "animated_gif") {
                    return NSURL(string: subJson["url"].stringValue)
                }
            }
        case .Text:
            return nil
            
        // Get video url
        case .Video:
            for (_, subJson) in tweet.data["media"] {
                
                // if type is video
                if (subJson["type"] == "video") {
                    return NSURL(string: subJson["url"].stringValue)!
                }
            }
        case .Photo:
            return nil
        }
        
        return nil
    }
    
    // MARK: - Private Helpers
    
    /**
        Get the type for the tweet. If tweet has multiple types then
        follow type hierarchy: Video > Gif > Photo > Text
     
        - Parameter tweet: A tweet in JSON format.
        - Returns: The type for the tweet.
     */
    private func getTypeForTweet(tweet: JSON) -> TweetType {
        
        // case JSON array
        let tags = tweet["tags"].arrayObject as! [String]
        
        // at least one tag exists
        if (tags.count > 0) {
            if tags.contains("video") {
                return .Video
            } else if tags.contains("animated_gif") {
                return .Gif
            } else if tags.contains("photo") {
                return .Photo
            }
        }
        
        // no tags, default text
        return .Text
    }
    
    /**
        Update UI when the first tweet of a certain type is received.
    
        - Parameter type: A tweet type.
     */
    private func turnOnFilterButtonForTweetType(type: TweetType) {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            NSNotificationCenter.defaultCenter().postNotificationName(kFIRST_TWEET_FOR_TYPE_NOTIFICATION, object: type.hashValue)
        }
    }
}