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
        
        var media = [[String: String]]()
        
        var urls = [String]()
        
        // Check for extended_entities
        let extended_entities = data["extended_entities"]
        
        if (extended_entities != nil) {
            media = parseExtendedEntities(extended_entities)
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
        let tweet : [String: AnyObject] = [   "screen_name": data["user"]["screen_name"].stringValue,
                        "profile_image_url": data["user"]["profile_image_url"].stringValue,
                        "text": data["text"].stringValue,
                        "extended_entities": media]
        
        return JSON(tweet)
    }
    
    /** 
        MARK: - Helper Methods
     */
    
    /**
        Parse entities into a simple format.
     
        - Parameter data: A JSON array of "entities" from a Twitter Stream.
        - Returns: An array of urls.
     */
    func parseEntities(data: JSON) {
        
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












