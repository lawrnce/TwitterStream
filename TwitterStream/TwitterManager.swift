//
//  TwitterManager.swift
//  TwitterStream
//
//  Created by lola on 4/29/16.
//  Copyright © 2016 LawrenceTran. All rights reserved.
//

import UIKit
import Social
import Accounts
import SwiftyJSON

protocol TwitterManagerDelegate {
    func twitterManager(twitterManager: TwitterManager, didStreamTweet tweet: JSON)
    func twitterManager(twitterManager: TwitterManager, failedWithErrorMessage error: String)
    func reconnectedToStream()
}

class TwitterManager: NSObject {
    
    var connected: Bool!
    var tryingToConnect: Bool!
    
    var delegate: TwitterManagerDelegate?
    
    // The current keyword to stream
    private var keyword: String!
    
    // Boolean to check if user paused the stream
    private var shouldPause: Bool!
    
    private var shouldReset: Bool!
    
    private var connection: NSURLConnection!
    
    override init() {
        super.init()
        self.connected = false
        self.tryingToConnect = false
        self.shouldPause = false
        self.shouldReset = false
    }
    
    /**
        Creates a new connection with a given keyword.
     
        - Parameter keyword: The keyword to track.
     */
    func createConnectionWithKeyword(keyword: String) {
        self.keyword = keyword
        
        if (self.shouldPause == true) {
            resumeStream()
            
        // Reset stream with new keyword if currently connected
        } else if (self.shouldReset == false && self.connection != nil) {
            self.shouldReset = true
            
        } else {
            createConnection()
        }
    }
    
    /**
        NSURLConnection cannot be paused. So we cancel it.
     */
    func pauseStream() {
        self.shouldPause = true
    }
    
    /**
        Create a new connection with the same keyword.
     */
    func resumeStream() {
        self.shouldPause = false
        createConnection()
    }

    /**
        Creates a real time stream for a keyword.
     
        - Parameter keyword: The keyword to stream.
     */
    func createConnection() {
        
        guard self.keyword != nil else {
            return
        }
        
        // User has access to Twitter
        if (self.userHasAccessToTwitter() == true) {
            
            // OAuth authentication
            let store = ACAccountStore()
            let twitterAccountType = store.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
            
            // Get permission to access Twitter
            store.requestAccessToAccountsWithType(twitterAccountType, options: nil, completion: { (granted, error) -> Void in
                
                // Error in requesting access
                if (error != nil) {
                    
                
                // Successfully request
                } else {
                    
                    // User denies access to Twitter
                    if (granted == false) {
                        
                        self.delegate?.twitterManager(self, failedWithErrorMessage: kTWITTER_ACCESS_DENIED)
                        
                    // User grants access to Twitter
                    } else {
                        
                        let twitterAccounts = store.accountsWithAccountType(twitterAccountType)
                        
                        if (twitterAccounts.count > 0) {
                            
                            // Get last Twitter account
                            let account = twitterAccounts.last as! ACAccount
                            
                            // Connect to Twitter endpoint
                            let url = NSURL(string: "https://stream.twitter.com/1.1/statuses/filter.json")
                            let params = [  "track": self.keyword,
                                            "filter_level": "low"]
                            let request = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: .POST, URL: url, parameters: params)
                            request.account = account
                            
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                self.connection = NSURLConnection(request: request.preparedURLRequest(), delegate: self)
                                self.connection?.start()
                            })
                            
                        }
                    }
                }
            })
            
        // User has no Twitter accounts. Notify the delegate.
        } else {
            self.delegate?.twitterManager(self, failedWithErrorMessage: kNO_TWITTER_ACCOUNT)
        }
    }
    
    /**
        Check if Compose View Controller is available for Twitter.
     
        - Returns: Boolean value if Twitter can be accessed.
     */
    func userHasAccessToTwitter() -> Bool {
        return SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter)
    }
}

extension TwitterManager: NSURLConnectionDataDelegate {
    
    /**
        When data is received, parse it to a JSON and notifiy delegate.
     */
    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        
        // Connection is async, so guarantee that the old stream is killed
        
        // Check if stream should reset with new keyword
        if (self.shouldReset == true) {
            self.shouldReset = false
            connection.cancel()
            createConnection()
            return
        }
        
        // Check if user paused stream
        if (self.shouldPause == true) {
            connection.cancel()
            print("Connection Paused")
            return
        }
        
        // Cast response data to JSON
        let json = JSON(data: data)
        
        // Check if valid JSON
        if (json != nil) {
            
            // Stream is connected
            self.connected = true
            
            if (self.tryingToConnect == true) {
                self.tryingToConnect = false
                self.delegate?.reconnectedToStream()
                print("Connected to stream")
            }
            
            // Init a parser
            let parser = TweetParser()
            
            // Parse tweet
            do {
                
                let tweet = try parser.parseTweetStream(json)
                
                // Notify delegate
                self.delegate?.twitterManager(self, didStreamTweet: tweet)
                
            } catch let error {
                print("Ignored invalid tweet: ", error)
            }
        }
    }
    
    func connection(connection: NSURLConnection, didFailWithError error: NSError) {
        
        self.connection = nil
        
        self.delegate?.twitterManager(self, failedWithErrorMessage: kCONNECTION_ERROR)
        
        self.connected = false
        self.tryingToConnect = true
        
        // reconnect to stream after 3 seconds
        self.performSelector(Selector("beginTwitterStream"), withObject: nil, afterDelay: 3)
    }
}