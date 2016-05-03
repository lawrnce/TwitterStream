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

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    /**
        Cell data on reuse
     */
    override func prepareForReuse() {
        
        // Start activity indicator
        self.activityIndicatorView.startAnimating()
        
        // Remove any subviews
        for subview in self.mediaView.subviews {
            subview.removeFromSuperview()
        }
        
        // Remove any gifs
//        if let sublayers = self.mediaView.layer.sublayers {
//            for layer in sublayers {
//                if (layer.classForCoder == AVPlayerLayer.self) {
//                    (layer as! AVPlayerLayer).player = nil
//                    layer.removeFromSuperlayer()
//                }
//            }
//        }
        
        // Clear profile image
        if (self.profileImageView.image != nil) {
            self.profileImageView.image = nil
        }
        
        // Clear screen name
        if (self.screenNameLabel.text?.isEmpty == false) {
            self.screenNameLabel.text = ""
        }
        
        // Clear text
        if (self.textView.text?.isEmpty == false) {
            self.textView.text = ""
        }
    }
}
