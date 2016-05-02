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
}

class TwitterManager: NSObject {
    
    var isConnected: Bool!
    var isTryingToConnect: Bool!
    
    var delegate: TwitterManagerDelegate?
    
    // Retrain current keyword to resume stream
    private var currentKeyword: String!
    
    // Boolean to check if user paused the stream
    private var shouldPause: Bool!
    
    override init() {
        super.init()
        self.isConnected = false
        self.isTryingToConnect = false
        self.shouldPause = false
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
        createStreamConnectionForKeyword(self.currentKeyword)
    }
    

    /**
        Creates a real time stream for a keyword.
     
        - Parameter keyword: The keyword to stream.
     */
    func createStreamConnectionForKeyword(keyword: String) {
        
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
                        
                        
                    // User grants access to Twitter
                    } else {
                        
                        let twitterAccounts = store.accountsWithAccountType(twitterAccountType)
                        
                        if (twitterAccounts.count > 0) {
                            
                            // Get last Twitter account
                            let account = twitterAccounts.last as! ACAccount
                            
                            // Connect to Twitter endpoint
                            let url = NSURL(string: "https://stream.twitter.com/1.1/statuses/filter.json")
                            let params = [  "track": keyword,
                                            "filter_level": "low"]
                            let request = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: .POST, URL: url, parameters: params)
                            request.account = account
                            
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                let connection = NSURLConnection(request: request.preparedURLRequest(), delegate: self)
                                connection?.start()
                                self.currentKeyword = keyword
                            })
                            
                        }
                    }
                }
            })
            
        // User has no Twitter accounts
        } else {
            
            
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
            self.isConnected = true
            
            if (self.isTryingToConnect == true) {
                self.isTryingToConnect = false
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
                print("There was an error: ", error)
            }
        }
    }
    
    func connection(connection: NSURLConnection, didCancelAuthenticationChallenge challenge: NSURLAuthenticationChallenge) {
        
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection) {
        
    }
    
    func connection(connection: NSURLConnection, didFailWithError error: NSError) {
        
        print(error)
    }
}