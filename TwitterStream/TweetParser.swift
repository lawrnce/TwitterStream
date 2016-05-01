//
//  StreamParser.swift
//  TwitterStream
//
//  Created by lola on 4/30/16.
//  Copyright © 2016 LawrenceTran. All rights reserved.
//

import Foundation
import SwiftyJSON

class TweetParser: NSObject {

    /**
        Parses raw tweet data to fetch profile image url, secreen name, and text.
    
        - Parameter data: The raw tweet data from a Twitter Stream.
        - Returns: A JSON of basic tweet data.
     */
    func parseTweetStream(data: JSON) -> JSON {
        
        var urls = [String]()
        
        // Check for entities in tweet
        let entities_urls = data["entities"]["urls"]
        
        if (entities_urls.isEmpty == false) {
            
            // Iterate through entities
            for (_, subJson) in entities_urls {
                urls.append(subJson["url"].stringValue)
            }
        }
        
        // Parse basic info
        let tweet = [   "screen_name": data["user"]["screen_name"].stringValue,
                        "profile_image_url": data["user"]["profile_image_url"].stringValue,
                        "text": data["text"].stringValue,
                        "entities_urls": urls]
        
        return JSON(tweet)
    }
}
