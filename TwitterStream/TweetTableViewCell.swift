//
//  TweetTableViewCell.swift
//  TwitterStream
//
//  Created by lola on 5/1/16.
//  Copyright © 2016 LawrenceTran. All rights reserved.
//

import UIKit
import AVFoundation

/**
    The tweet's delegate
 */
protocol TweetTableViewCellDelegate {
    func tweetTableViewCell(tweetTableViewCell: TweetTableViewCell, didPressPlayButton url: NSURL)
}

class TweetTableViewCell: UITableViewCell {

    // Outlets
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var mediaView: UIView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var playButton: UIButton!
    
    var delegate: TweetTableViewCellDelegate?
    
    // If tweet contains video, store the url path
    var videoURL: NSURL!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.playButton.hidden = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // Notify the delegate that play button was pressed
    @IBAction func playButtonDidPress(sender: AnyObject) {
        if (self.videoURL != nil) {
            delegate?.tweetTableViewCell(self, didPressPlayButton: self.videoURL)
        }
    }
    
    /**
        Cell data on reuse
     */
    override func prepareForReuse() {
        
        // Initially hide play button
        self.playButton.hidden = true
        self.videoURL = nil
        
        self.activityIndicatorView.startAnimating()
        
        // Remove any subviews
        for subview in self.mediaView.subviews {
            subview.removeFromSuperview()
        }
        
        // Remove any gifs
        if let sublayers = self.mediaView.layer.sublayers {
            for layer in sublayers {
                if (layer.classForCoder == AVPlayerLayer.self) {
                    (layer as! AVPlayerLayer).player = nil
                    layer.removeFromSuperlayer()
                }
            }
        }
        
        if (self.profileImageView.image != nil) {
            self.profileImageView.image = nil
        }
        
        if (self.screenNameLabel.text?.isEmpty == false) {
            self.screenNameLabel.text = ""
        }
        
        if (self.textView.text?.isEmpty == false) {
            self.textView.text = ""
        }
    }
}
