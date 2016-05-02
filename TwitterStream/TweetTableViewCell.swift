//
//  TweetTableViewCell.swift
//  TwitterStream
//
//  Created by lola on 5/1/16.
//  Copyright © 2016 LawrenceTran. All rights reserved.
//

import UIKit

class TweetTableViewCell: UITableViewCell {

    // Outlets
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var mediaView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    /**
        Cell data on reuse
     */
    override func prepareForReuse() {
        if profileImageView.image != nil {
            profileImageView.image = nil
        }
//
        if (screenNameLabel.text?.isEmpty == false) {
            screenNameLabel.text = ""
        }
        
    }
}
