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
        var photos = [[String: String]]()
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
        
        // Parse entities
        // eg: links, photos
        if (data["entities"].isExists()) {
            let entities: (photos: [[String: String]], links: [String], tags: [String]) = parseEntities(data["entities"])
            photos = entities.photos
            urls = entities.links
            tags += entities.tags
        }
        
        // Parse basic info
        let tweet : [String: AnyObject] = [
                        "tags": tags,
                        "screen_name": data["user"]["screen_name"].stringValue,
                        "profile_image_url": data["user"]["profile_image_url"].stringValue,
                        "text": data["text"].stringValue,
                        "media": media,
                        "photos": photos,
                        "links" :urls]
        
        return tweet
    }
    
    /** 
        MARK: - Helper Methods
     */
    
    /**
        Parses entities as links or photos.
     
        - Parameter data: A JSON array of "entities" from a Twitter Stream.
        - Returns: A tupe containg array of photo dictionaries and array of links.
     */
    private func parseEntities(data: JSON) -> (photos: [[String: String]], links: [String], tags: [String]) {
        
        var photos = [[String: String]]()
        var links = [String]()
        var tags = [String]()
        
        // Check if media entity exsits
        if (data["media"].isExists()) {
            
            // parse photos
            for (_, subJson) in data["media"] {
                if let photo = parsePhoto(subJson) {
                    photos.append(photo)
                }
            }
        }
        
        // Check if url entity exists
        if (data["url"].isExists()) {
    
            // parse links
            for (_, subJson) in data {
                
                // check if link is not missing
                if (subJson["url"].stringValue != "-1") {
                    links.append(subJson["url"].stringValue)
                }
            }
        }
   
        // set tags
        if photos.count > 0 {
            tags.append("photo")
        }
        
        if links.count > 0 {
            tags.append("link")
        }
        
        return (photos, links, tags)
    }
    
    /**
        Parses an entity in the "media" subJSON. This will always be a photo.

        - Parameter data: An element of the "media" subJSON in "entities."
        - Returns: A dictionary representing a photo. nil if photo was invalid.
     */
    private func parsePhoto(data: JSON) -> [String: String]? {
        
        var photo: [String: String]!
        
        // Get only media with tag "photo"
        // "-1" means url is missing.
        if (data["type"] == "photo" && data["media_url"].stringValue != "-1") {
            
            photo = [String: String]()

            // set type
            photo["type"] = "photo"
            
            // set image url
            photo["url"] = data["media_url"].stringValue
        }
        
        return photo
    }
    
    /**
        Parse extended entities into a readable format.
     
        - Parameter data: A JSON array of "extended_entites" from a Twitter Stream.
        - Returns: A tuple containing an array dictionaries describing each media file and any tags.
     */
    private func parseExtendedEntities(data: JSON) -> (media: [[String: String]], tags: [String]) {
        
        // use a set so that when we convert to array
        // any duplicates are discarded
        var tagSet = Set<String>()
        
        var media = [[String: String]]()
        
        // iterate through the media and parse any media entities and get its tag
        for (_, subJson) in data["media"] {
            if let entity: (media_entity: [String: String], tag: String) = parseMedia(subJson) {
                media.append(entity.media_entity)
                tagSet.insert(entity.tag)
            }
        }
        
        // remove any repeating tags
        let tags = Array(tagSet)
        
        return (media, tags)
    }
    
    /**
        Parases an extended entity as a video or gif.
     
        - Parameter data: An element of the "media" subJSON in "extended_entities."
        - Returns: A optional tuple containing a dictionary describing a media file and a tag.
     */
    private func parseMedia(data: JSON) -> (media_entity: [String: String], tag: String)? {
        
        var media = [String: String]()
        var tag: String!
        
        // Iterate through variants
        for (_, subJson) in data["video_info"]["variants"] {
            
            // Check that "type" field is filled
            if let type = data["type"].string {
                
                // Check if thumbnail image is missing
                if (data["media_url"].stringValue == "-1") {
                    break
                }
                
                // Check content typ for mp4 && bit rate 832000 (video) or 0 (gif)
                if (subJson["content_type"].stringValue == "video/mp4" && subJson["bitrate"].int < 832001) {
                    
                    // Check if media url is missing
                    if (subJson["url"].stringValue == "-1") {
                        break
                    }
                    
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
        }

        // if the tag is empty, then no media was parsed
        if (tag == nil) {
            return nil
        } else {
            return (media, tag)
        }
    }
}