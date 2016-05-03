//
//  TwitterTests.swift
//  TwitterStream
//
//  Created by lola on 4/30/16.
//  Copyright © 2016 LawrenceTran. All rights reserved.
//

import XCTest
import Nimble

@testable import TwitterStream

class TwitterManagerTests: XCTestCase {
    
    var twitterManager: TwitterManager!
    
    override func setUp() {
        super.setUp()
        self.twitterManager = TwitterManager()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    /**
        Check if Twitter stream connects.
     */
    func test_twitter_stream_responds_with_data_type_json() {
        self.twitterManager.createConnectionWithKeyword("test")
        expect(self.twitterManager.connected).toEventually(beTruthy(), timeout: 5)
    }
}
