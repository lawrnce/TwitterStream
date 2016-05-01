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
        
        let media = [String]()
        
        var urls = [String]()
        
        // Check for extended_entities
        let extended_entities = data["extended_entities"]
        
        if (extended_entities != nil) {

        }
        
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
                        "entities": urls,
                        "extended_entities": media]
        
        return JSON(tweet)
    }
    
    /**
        Parse extended entities into a readable format.
     
        - Parameter data: A JSON array of "extended_entites" from a Twitter Stream.
        - Returns: A parsed JSON representing media.
     */
    func parseExtendedEntities(data: JSON) {
        
    }
    
    /** 
        Parse entities into a simple format.
     
        - Parameter data: A JSON array of "entities" from a Twitter Stream.
        - Returns: An array of urls.
     */
    func parseEntities(data: JSON) {
        
    }
    
    /**
        Parases extended entities for video media.
    
        - Parameter data: A JSON of "extended_entites" from a Twitter Stream.
        - Returns: A parsed JSON for video.
     */
    func parseVideo(data: JSON) {
        
    }
}












