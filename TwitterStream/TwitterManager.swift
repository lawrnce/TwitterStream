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

class TwitterManager: NSObject {
    
    // For unit testing. Expect data stream to be working. 
    var dataDidBeginStreaming: Bool!

    func initStreamingConnectionForPatter(keyword: String) {
        
        if (self.userHasAccessToTwitter() == true) {
            
            // OAuth authentication
            let store = ACAccountStore()
            let twitterAccountType = store.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
            
            // Get permission to access Twitter
            store.requestAccessToAccountsWithType(twitterAccountType, options: nil, completion: { (granted, error) -> Void in
                
                if (error != nil) {
                    
                } else {
                    
                    if (granted == false) {
                        
                        
                    } else {
                        
                        let twitterAccounts = store.accountsWithAccountType(twitterAccountType)
                        
                        if (twitterAccounts.count > 0) {
                            
                            let account = twitterAccounts.last as! ACAccount
                            let url = NSURL(string: "https://stream.twitter.com/1.1/statuses/filter.json")
                            let params = ["track": "anime"]
                            let request = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: .POST, URL: url, parameters: params)
                            request.account = account
                            
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                let connection = NSURLConnection(request: request.preparedURLRequest(), delegate: self)
                                connection?.start()
                            })
                            
                        }
                    }
                }
            })
            
        // No access to twitter
        } else {
            
            
        }
    }
    
    func userHasAccessToTwitter() -> Bool {
        return SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter)
    }
}

extension TwitterManager: NSURLConnectionDataDelegate {
    
    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        print(JSON(data: data))
        
        if (self.dataDidBeginStreaming == false) {
            self.dataDidBeginStreaming = true
        }
    }
    
    func connection(connection: NSURLConnection, didFailWithError error: NSError) {
        
        print(error)
    }
}






