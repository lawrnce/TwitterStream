//
//  TweetTableViewCell.swift
//  TwitterStream
//
//  Created by lola on 5/1/16.
//  Copyright © 2016 LawrenceTran. All rights reserved.
//

import UIKit
import AVFoundation

class TweetTableViewCell: UITableViewCell {

    // Outlets
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var mediaView: UIView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    // Media
    var videoItem: AVPlayerItem!
    var videoPlayer: AVPlayer!
    var avLayer: AVPlayerLayer!
    
    // photo
    var photoImageView: UIImageView!
    
    // MARK: - GIF
    
    /**
        Creates the AV items required to loop a gif.
     */
    func setGifWithURL(url: NSURL) {
        // setup video player
        self.videoItem = AVPlayerItem(URL: url)
        self.videoPlayer = AVPlayer(playerItem: self.videoItem)
        self.avLayer = AVPlayerLayer(player: self.videoPlayer)
        self.avLayer.videoGravity = AVLayerVideoGravityResizeAspect
        self.avLayer.frame = self.mediaView.bounds
        self.mediaView.layer.addSublayer(self.avLayer)
        self.activityIndicatorView.stopAnimating()
        
        // play
        self.videoPlayer.play()
//        NSNotificationCenter.defaultCenter().addObserverForName(AVPlayerItemDidPlayToEndTimeNotification, object: videoPlayer.currentItem, queue: nil) { notification in
//            self.videoPlayer.seekToTime(kCMTimeZero)
//            self.videoPlayer.play()
//        }
    }
    
    /**
        Set a player to loop for a gif.
     */
    private func loopVideo(videoPlayer: AVPlayer) {

    }
    
    // MARK: - VIDEO
    
    
    // MARK: - PHOTO
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    /**
        Cell data on reuse
     */
    override func prepareForReuse() {
        
        if (self.videoPlayer != nil) {
            NSNotificationCenter.defaultCenter().removeObserver(self.videoPlayer.currentItem!)
            self.videoPlayer = nil
            self.videoItem = nil
        }
        
        self.activityIndicatorView.startAnimating()
        
        if (self.profileImageView.image != nil) {
            profileImageView.image = nil
        }
        
        if (self.screenNameLabel.text?.isEmpty == false) {
            self.screenNameLabel.text = ""
        }
        
        if (self.textView.text?.isEmpty == false) {
            self.textView.text = ""
        }
        
        for subview in self.mediaView.subviews {
            subview.removeFromSuperview()
        }
        
        if let sublayers = self.mediaView.layer.sublayers {
            for sublayer in sublayers {
                sublayer.removeFromSuperlayer()
            }
        }

    }
}
