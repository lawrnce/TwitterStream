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
        if (self.videoPlayer != nil) {
            self.videoPlayer = nil
        }
        if (self.videoItem != nil) {
            self.videoItem = nil
        }
    }
}
