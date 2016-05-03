//
//  TweetsModelTests.swift
//  TwitterStream
//
//  Created by lola on 5/1/16.
//  Copyright © 2016 LawrenceTran. All rights reserved.
//

import XCTest
import Nimble
import SwiftyJSON
@testable import TwitterStream

class TweetsModelTests: XCTestCase {
    
    var tweets: TweetsModel!
    
    // Test Data
    let videoTweet = JSON([ "tags": ["video"],
        "media": [["type": "video", "thumbnail_url": "some_url", "url": "some_url"]]])
    
    let photoTweet = JSON([ "tags": ["photo"],
        "photos": [["type": "photo", "url": "some_url"]]])
    
    let gifTweet = JSON([   "tags": ["animated_gif"],
        "media": [["type": "animated_gif", "url": "some_url"]]])
    
    let textTweet = JSON([   "tags": [], "media": []])
    
    override func setUp() {
        super.setUp()
        self.tweets = TweetsModel()
    }
    
    override func tearDown() {
        self.tweets = nil
        super.tearDown()
    }
    
    // MARK: - Insert Functional Tests
    
    /**
        Inserting tweets into model should add to hash.
     */
    func test_tweets_model_inserts_tweet_into_hash() {
        
        self.tweets.insertTweet(videoTweet, completion: nil)
        self.tweets.insertTweet(photoTweet, completion: nil)
        self.tweets.insertTweet(gifTweet, completion: nil)
        
        expect(self.tweets.count).to(equal(3))
    }
    
    
    /**
        Inserting a gif tweet should append to gif list.
     */
    func test_tweets_model_insert_gif_tweet_appends_to_gif_list() {
        
        self.tweets.insertTweet(gifTweet, completion: nil)
        
        expect(self.tweets.countForType(.Gif)).to(equal(1))
    }
    
    /**
        Inserting a text tweet should append to text list.
     */
    func test_tweets_model_insert_text_tweet_appends_to_text_list() {
        
        self.tweets.insertTweet(textTweet, completion: nil)
        
        expect(self.tweets.countForType(.Text)).to(equal(1))
    }
    
    /**
        Inserting a video tweet should append to video list.
     */
    func test_tweets_model_insert_video_tweet_appends_to_video_list() {
        
        self.tweets.insertTweet(videoTweet, completion: nil)
        
        expect(self.tweets.countForType(.Video)).to(equal(1))
    }
    
    /**
        Inserting a photo tweet should append to photo list.
     */
    func test_tweets_model_insert_photo_tweet_appends_to_photo_list() {
        
        self.tweets.insertTweet(photoTweet, completion: nil)
        
        expect(self.tweets.countForType(.Photo)).to(equal(1))
    }
    
    // MARK: - Get Functional Tests
    
    /**
        Get gif tweet should return Gif type.
     */
    func test_get_gif_tweet_should_return_gif_type() {
        
        self.tweets.insertTweet(gifTweet, completion: nil)
        
        // only 1 tweet with key 0
        let type: TweetType = self.tweets.typeForKey(0)
        
        expect(type).to(equal(TweetType.Gif))
    }
    
    /**
        Get text tweet should return Text type.
     */
    func test_get_text_tweet_should_return_text_type() {
        
        self.tweets.insertTweet(textTweet, completion: nil)
        
        // only 1 tweet with key 0
        let type: TweetType = self.tweets.typeForKey(0)
        
        expect(type).to(equal(TweetType.Text))
    }
    
    /**
        Get video tweet should return Video type.
     */
    func test_get_video_tweet_should_return_video_type() {
        
        self.tweets.insertTweet(videoTweet, completion: nil)
        
        // only 1 tweet with key 0
        let type: TweetType = self.tweets.typeForKey(0)
        
        expect(type).to(equal(TweetType.Video))
    }
    
    /**
        Get photo tweet should return Photo type.
     */
    func test_get_photo_tweet_should_return_photo_type() {
        
        self.tweets.insertTweet(photoTweet, completion: nil)
        
        // only 1 tweet with key 0
        let type: TweetType = self.tweets.typeForKey(0)
        
        expect(type).to(equal(TweetType.Photo))
    }
    
    // MARK: - Filter Functional Tests
    
    /**
        Gif filter should toggle.
     */
    func test_gif_filter_should_return_false_after_toggle() {
        
        self.tweets.toggleFilterForType(.Gif)
        
        
    }
    
    /**
        Test tweet filtering.
     */
    func test_tweets_model_filters_order_ascending() {
    
        // add dummy tweet data
//        self.tweets.insertTweet([String: String](), forType: .Text)   // 0
//        self.tweets.insertTweet([String: String](), forType: .Gif)    // 1
//        self.tweets.insertTweet([String: String](), forType: .Gif)    // 2
//        self.tweets.insertTweet([String: String](), forType: .Text)   // 3
//        self.tweets.insertTweet([String: String](), forType: .Photo)  // 4
//        self.tweets.insertTweet([String: String](), forType: .Text)   // 5
//        self.tweets.insertTweet([String: String](), forType: .Video)  // 6
        
        // filter gif text
//        let filter = (true, true, false, false)
//        
//        let filteredList = self.tweets.filterTweets(filter)
//        
//        expect(filteredList).to(equal([0, 1, 2, 3, 5]))
    }
    
    // MARK: - Performance tests
}