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
        Also parses entities and extended_entities for videos, gifs, and images.
    
        - Parameter data: The raw tweet data from a Twitter Stream.
        - Returns: A dictionary representing a tweet.
     */
    func parseTweetStream(data: JSON) -> [String: AnyObject] {
        
        // Create objects first so even if empty, dictionary contains empty instead of nil
        var media = [[String: String]]()
        var urls = [String]()
        
        // Tag each tweet for filtering
        var tags = [String]()
        
        // Parse extended entities if exist
        // eg: videos, animated_gifs
        if (data["extended_entities"].isExists()) {
            let extended_entities: (media: [[String: String]], tags: [String]) = parseExtendedEntities(data["extended_entities"])
            media = extended_entities.media
            tags += extended_entities.tags
        }
        
        // Parse url entities if exist
        // eg: links, photos
        if (data["entities"]["urls"].isExists()) {
            urls = parseURLEntities(data["entities"]["urls"])
        }
        
        // Parse basic info
        let tweet : [String: AnyObject] = [
                        "tags": tags,
                        "screen_name": data["user"]["screen_name"].string!,
                        "profile_image_url": data["user"]["profile_image_url"].string!,
                        "text": data["text"].string!,
                        "extended_entities": media,
                        "entities": urls]
        
        return tweet
    }
    
    /** 
        MARK: - Helper Methods
     */
    
    /**
        Parses entities as links or photos.
     
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
        - Returns: A tuple containing an array dictionaries describing each media file and any tags.
     */
    func parseExtendedEntities(data: JSON) -> (media: [[String: String]], tags: [String]) {
        
        var media = [[String: String]]()
        var tags = [String]()
        
        // iterate through the media and parse any media entities and get its tag
        for (_, subJson) in data["media"] {
            let entity: (media_entity: [String: String], tag: String)  = parseMedia(subJson)
            media.append(entity.media_entity)
            tags.append(entity.tag)
        }
        
        return (media, tags)
    }
    
    /**
        Parases an extended entity as a video or gif.
     
        - Parameter data: An element of the "media" array in "extended_entities".
        - Returns: A tuple containing a dictionary describing a media file and a tag.
     */
    func parseMedia(data: JSON) -> (media_entity: [String: String], tag: String) {
        
        var media = [String: String]()
        var tag: String!
        
        // Iterate through variants
        for (_, subJson) in data["video_info"]["variants"] {
            
            // Check content typ for mp4 && bit rate 832000 (video) or 0 (gif)
            if (subJson["content_type"].stringValue == "video/mp4" && subJson["bitrate"].int < 832001) {
                
                let type = data["type"].stringValue
                
                // Add type
                media["type"] = type
                
                // Add tag for filtering
                tag = type
                
                // Get thumbnail image url
                media["thumbnail_url"] = data["media_url"].stringValue
                
                // Get content url
                media["url"] = subJson["url"].stringValue
            }
        }
        
        return (media, tag)
    }
}