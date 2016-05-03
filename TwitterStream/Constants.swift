//
//  Constants.swift
//  TwitterStream
//
//  Created by lola on 5/1/16.
//  Copyright © 2016 LawrenceTran. All rights reserved.
//

import UIKit

let kSCREEN_WIDTH = UIScreen.mainScreen().bounds.width
let kSCREEN_HEIGHT = UIScreen.mainScreen().bounds.height

/** 
    Notifications
 */
let kFIRST_TWEET_FOR_TYPE_NOTIFICATION = "com.lawrnce.FirstTweetForTypeNotification"

/**
    Table view constants
 */
let kTweetTableViewCellReuseIdentifier = "com.lawrnce.TweetTableViewCellReuseIdentifier"

/**
    Table view cell layout constants
 */
let kTWEET_CELL_PADDING = CGFloat(8.0)
let kTWEET_SCREEN_NAME_HEIGHT = CGFloat(20.0)
let kTWEET_MEDIA_ITEM_HEIGHT = CGFloat(150.0)
let kTWEET_TEXT_VIEW_WIDTH = CGFloat(80)

let kTWEET_TEXT_VIEW_SIZE = CGSize(width: kTWEET_TEXT_VIEW_WIDTH, height: 50.0)
let kTEXT_TWEET_BASE_HEIGHT = kTWEET_CELL_PADDING * 2.0 + kTWEET_SCREEN_NAME_HEIGHT + kTWEET_TEXT_VIEW_WIDTH
let kMEDIA_TWEET_BASE_HEIGHT = kTWEET_CELL_PADDING * 2.0 + kTWEET_SCREEN_NAME_HEIGHT + kTWEET_MEDIA_ITEM_HEIGHT + kTWEET_TEXT_VIEW_WIDTH

/**
    Error Messages
 */
let kTWITTER_ACCESS_DENIED = "Twitter access is denied. Allows access in Settings under Twitter."
let kNO_TWITTER_ACCOUNT = "No twitter account detected. You must have a Twitter account on this phone."
let kCONNECTION_ERROR = "Connection failed. Attempting to reconnect."