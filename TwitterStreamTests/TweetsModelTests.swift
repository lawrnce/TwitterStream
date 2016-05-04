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
    var videoTweet: JSON!
    var photoTweet: JSON!
    var gifTweet: JSON!
    var textTweet: JSON!

    override func setUp() {
        super.setUp()
        self.tweets = TweetsModel()
        self.videoTweet = JSON([ "tags": ["video"],
            "media": [["type": "video", "thumbnail_url": "some_url", "url": "some_url"]]])
        self.photoTweet = JSON([ "tags": ["photo"],
            "photos": [["type": "photo", "url": "some_url"]]])
        self.gifTweet = JSON([   "tags": ["animated_gif"],
            "media": [["type": "animated_gif", "url": "some_url"]]])
        self.textTweet = JSON([   "tags": [], "media": []])
    }
    
    override func tearDown() {
        self.tweets = nil
        self.videoTweet = nil
        self.photoTweet = nil
        self.textTweet = nil
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
        let type: TweetType = self.tweets.typeForKey(0)
        expect(type).to(equal(TweetType.Gif))
    }
    
    /**
        Get text tweet should return Text type.
     */
    func test_get_text_tweet_should_return_text_type() {
        self.tweets.insertTweet(textTweet, completion: nil)
        let type: TweetType = self.tweets.typeForKey(0)
        expect(type).to(equal(TweetType.Text))
    }
    
    /**
        Get video tweet should return Video type.
     */
    func test_get_video_tweet_should_return_video_type() {
        self.tweets.insertTweet(videoTweet, completion: nil)
        let type: TweetType = self.tweets.typeForKey(0)
        expect(type).to(equal(TweetType.Video))
    }
    
    /**
        Get photo tweet should return Photo type.
     */
    func test_get_photo_tweet_should_return_photo_type() {
        self.tweets.insertTweet(photoTweet, completion: nil)
        let type: TweetType = self.tweets.typeForKey(0)
        expect(type).to(equal(TweetType.Photo))
    }
    
    // MARK: - Filter Functional Tests
    
    /**
        Gif filter should toggle.
     */
    func test_gif_filter_should_return_false_after_toggle() {
        self.tweets.toggleFilterForType(.Gif)
        expect(self.tweets.filterStateForType(.Gif)).to(beFalse())
    }
    
    /**
        Text filter should toggle.
     */
    func test_text_filter_should_return_false_after_toggle() {
        self.tweets.toggleFilterForType(.Text)
        expect(self.tweets.filterStateForType(.Text)).to(beFalse())
    }
    
    /**
        Video filter should toggle.
     */
    func test_video_filter_should_return_false_after_toggle() {
        self.tweets.toggleFilterForType(.Video)
        expect(self.tweets.filterStateForType(.Video)).to(beFalse())
    }
    
    /**
        Photo filter should toggle.
     */
    func test_photo_filter_should_return_false_after_toggle() {
        self.tweets.toggleFilterForType(.Photo)
        expect(self.tweets.filterStateForType(.Photo)).to(beFalse())
    }
    
    /**
        Tweet filter should return according keys.
     */
    func test_tweets_model_filters_order_ascending() {
    
        // Add tweets
        self.tweets.insertTweet(videoTweet, completion: nil)    // 0
        self.tweets.insertTweet(gifTweet, completion: nil)      // 1
        self.tweets.insertTweet(textTweet, completion: nil)     // 2
        self.tweets.insertTweet(gifTweet, completion: nil)      // 3
        self.tweets.insertTweet(photoTweet, completion: nil)    // 4
        self.tweets.insertTweet(videoTweet, completion: nil)    // 5
        self.tweets.insertTweet(gifTweet, completion: nil)      // 6
        
        // Set filter for only gif and text
        self.tweets.toggleFilterForType(.Video)
        self.tweets.toggleFilterForType(.Photo)

        expect(self.tweets.filteredTweets()).to(equal([6, 3, 2, 1]))
    }
    
    // MARK: - Performance tests
    
    /**
        Insert tweet performance
        ~ 0.074 sec (37% STDEV) on iPhone 6+
     */
    func test_performance_insert_1000_tweets() {
        self.measureBlock {
            for _ in 0...250 {
                self.tweets.insertTweet(self.gifTweet, completion: nil)
                self.tweets.insertTweet(self.textTweet, completion: nil)
                self.tweets.insertTweet(self.videoTweet, completion: nil)
                self.tweets.insertTweet(self.photoTweet, completion: nil)
                
            }
        }
    }
    
    /**
        Filter tweets performance
        ~ 0.004 sec (27% STDEV) on iPhone 6+
     */
    func test_perforrmance_filter_1000_tweets() {
        
        // insert 1000 tweets
        for _ in 0...250 {
            self.tweets.insertTweet(self.gifTweet, completion: nil)
            self.tweets.insertTweet(self.textTweet, completion: nil)
            self.tweets.insertTweet(self.videoTweet, completion: nil)
            self.tweets.insertTweet(self.photoTweet, completion: nil)
        }
        
        // set a filter
        self.tweets.toggleFilterForType(.Gif)
        
        self.measureBlock { () -> Void in
            self.tweets.filteredTweets()
        }
    }
}