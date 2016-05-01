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
        let tweet = [   "screen_name": data["user"]["screen_name"],
                        "profile_image_url": data["user"]["profile_image_url"],
                        "text": data["text"]]
        
        
        
        return JSON(tweet)
    }
}
