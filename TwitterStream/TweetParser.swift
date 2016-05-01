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
        let tweet : [String: AnyObject] = [   "screen_name": data["user"]["screen_name"].stringValue,
                        "profile_image_url": data["user"]["profile_image_url"].stringValue,
                        "text": data["text"].stringValue,
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
            
            // Check media type
            if (subJson["type"].isExists()) {
                
                let type = subJson["type"].stringValue
                
                // Check if video
                if (type == "video") {
                    extended_entities.append(parseVideo(subJson))
                    
                // Check if gif
                } else if (type == "animated_gif") {
                    
                }
            }
        }
        
        return extended_entities
    }
    
    /**
        Parases extended entities for video media. Gets the thumbnail and the 
        HLS streming format.
    
        - Parameter data: A JSON of "extended_entites" from a Twitter Stream.
        - Returns: A dictionary describing a video file.
     */
    func parseVideo(data: JSON) -> [String: String] {
        
        var video = [String: String]()
        
        // Iterate through video variants
        for (_, subJson) in data["video_info"]["variants"] {
            
            // Get HLS Streaming format video url
            if (subJson["content_type"].stringValue == "application/x-mpegURL") {
                video["url"] = subJson["url"].stringValue
                
                // Add type
                video["type"] = "video"
                
                // Get thumbnail image url
                video["thumbnail_url"] = data["media_url"].stringValue
            }
        }
        return video
    }
}