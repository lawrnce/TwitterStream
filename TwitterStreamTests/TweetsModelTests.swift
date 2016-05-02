//
//  TweetsModelTests.swift
//  TwitterStream
//
//  Created by lola on 5/1/16.
//  Copyright © 2016 LawrenceTran. All rights reserved.
//

import XCTest
import Nimble
@testable import TwitterStream

class TweetsModelTests: XCTestCase {
    
    var tweets: TweetsModel!
    
    override func setUp() {
        super.setUp()
        self.tweets = TweetsModel()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    /**
        Test tweet filtering.
     */
    func test_tweets_model_filters_order_ascending() {
        
        // add dummy tweet data
        self.tweets.insertTweet([String: String](), forType: .Text)   // 0
        self.tweets.insertTweet([String: String](), forType: .Gif)    // 1
        self.tweets.insertTweet([String: String](), forType: .Gif)    // 2
        self.tweets.insertTweet([String: String](), forType: .Text)   // 3
        self.tweets.insertTweet([String: String](), forType: .Photo)  // 4
        self.tweets.insertTweet([String: String](), forType: .Text)   // 5
        self.tweets.insertTweet([String: String](), forType: .Video)  // 6
        
        // filter text and video
        let filter = (false, true, true, false)
        
        let filteredList = self.tweets.filterTweets(filter)
        
        expect(filteredList).to(equal([0, 3, 5, 6]))
    }
}
