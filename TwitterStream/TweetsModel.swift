//
//  TweetsModel.swift
//  TwitterStream
//
//  Created by lola on 5/1/16.
//  Copyright © 2016 LawrenceTran. All rights reserved.
//

import Foundation

enum TweetType {
    case Gif
    case Text
    case Video
    case Photo
}

/**
    Data structure to store tweets and allow for fast filtering.
 */
class TweetsModel: NSObject {

    // Map each tweet to an integer key.
    private var tweetHash: [Int: AnyObject]!
    
    // List of gif tweets
    private var gifList: [Int]!
    
    // List of text tweets
    private var textList: [Int]!
    
    // List of video tweets
    private var videoList: [Int]!
    
    // List of photo tweets
    private var photoList: [Int]!
    
    override init() {
        super.init()
        self.tweetHash = [Int: AnyObject]()
        self.textList = [Int]()
        self.gifList = [Int]()
        self.videoList = [Int]()
        self.photoList = [Int]()
    }
    
    /**
        Add tweet to hash and append it to its type list.
     */
    func insertTweet(tweet: [String: AnyObject], forType type: TweetType) {
        
        // get next key for hash
        let key = self.tweetHash.count
        
        // set tweet hash
        self.tweetHash[key] = tweet
        
        // append key to type list
        switch (type) {
        case .Text:
            self.textList.append(key)
        case .Gif:
            self.gifList.append(key)
        case .Video:
            self.videoList.append(key)
        case .Photo:
            self.photoList.append(key)
        }
    }
    
    /**
        Return a filtered list of keys.
    
        - Parameter filter: The set of booleans representing which filters are active.
        - Returns: An array of keys for the filtered tweets.
     */
    func filterTweets(filter: (gif: Bool, text: Bool, video: Bool, photo: Bool)) -> [Int] {
        var keys = [Int]()
        
        // filter gif tweets
        if (filter.gif == true) {
            keys += self.gifList
        }
        
        // filter text tweets
        if (filter.text == true) {
            keys += self.textList
        }
        
        // filter video tweets
        if (filter.video == true) {
            keys += self.videoList
        }
        
        // filter photo tweets
        if (filter.photo == true) {
            keys += self.photoList
        }
        
        // order keys
        keys.sortInPlace({ $0 < $1 })
        
        return keys
    }
}