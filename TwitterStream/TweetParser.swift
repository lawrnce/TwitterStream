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
        
        // Create objects first so even if empty, JSON contains empty instead of nil
        var media = [[String: String]]()
        var urls = [String]()
        
        // Parse extended entities if exist
        // Video, animated gifs
        if (data["extended_entities"].isExists()) {
            media = parseExtendedEntities(data["extended_entities"])
        }
        
        // Parse url entities if exist
        // links, photos
        if (data["entities"]["urls"].isExists()) {
            urls = parseURLEntities(data["entities"]["urls"])
        }
        
        // Parse basic info
        let tweet : [String: AnyObject] = [   "screen_name": data["user"]["screen_name"].string!,
                        "profile_image_url": data["user"]["profile_image_url"].string!,
                        "text": data["text"].string!,
                        "extended_entities": media,
                        "entities": urls]
        
        return JSON(tweet)
    }
    
    /** 
        MARK: - Helper Methods
     */
    
    /**
        Parse url entities into a simple array.
     
        - Parameter data: A JSON array of "entities" from a Twitter Stream.
        - Returns: An array of string urls.
     */
    func parseURLEntities(data: JSON) -> [String] {
        var entities = [String]()
        
        for (_, subJson) in data {
            entities.append(subJson["url"].stringValue)
        }
        
        return entities
    }
    
    /**
        Parse extended entities into a readable format.
     
        - Parameter data: A JSON array of "extended_entites" from a Twitter Stream.
        - Returns: An array dictionaries describing each media file.
     */
    func parseExtendedEntities(data: JSON) -> [[String: String]] {
        
        var extended_entities = [[String: String]]()
        
        for (_, subJson) in data["media"] {
            extended_entities.append(parseMedia(subJson))
        }
        
        return extended_entities
    }
    
    /**
        Parases extended entities for videos or gifs.
     
        - Parameter data: A JSON of "extended_entites" from a Twitter Stream.
        - Returns: A dictionary describing a video file.
     */
    func parseMedia(data: JSON) -> [String: String] {
        
        var media = [String: String]()
        
        // Iterate through variants
        for (_, subJson) in data["video_info"]["variants"] {
            
            // Check content typ for mp4 && bit rate 832000 (video) or 0 (gif)
            if (subJson["content_type"].stringValue == "video/mp4" && subJson["content_type"].int < 832001) {
                
                // Add type
                media["type"] = data["type"].stringValue
                
                // Get thumbnail image url
                media["thumbnail_url"] = data["media_url"].stringValue
                
                // Get content url
                media["url"] = subJson["url"].stringValue
            }
        }
        
        return media
    }
}




