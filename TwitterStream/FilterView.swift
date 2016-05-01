//
//  FilterView.swift
//  TwitterStream
//
//  Created by lola on 5/1/16.
//  Copyright © 2016 LawrenceTran. All rights reserved.
//

import UIKit

/**
    Notifies the delegate of state change.
 */
protocol FilterViewDelegate {
    func filterView(filterView: FilterView, didToggleFilterForType type: TweetType)
    func didTogglePlayback()
}

@IBDesignable class FilterView: UIView {

    var delegate: FilterViewDelegate?
    
    // nib properties
    var view: UIView!
    
    // outlets
    @IBOutlet weak var playbackButton: UIButton!
    @IBOutlet weak var videoFilterButton: UIButton!
    @IBOutlet weak var gifFilterButton: UIButton!
    @IBOutlet weak var textFilterButton: UIButton!
    @IBOutlet weak var photoFilterButton: UIButton!
    
    
    // inspectable
    @IBInspectable dynamic var playbackButtonImage: UIImage? {
        get {
            return playbackButton.imageForState(.Normal)
        }
        set(image) {
            playbackButton.setImage(image, forState: .Normal)
        }
    }

    @IBInspectable dynamic var gifFilterButtonImage: UIImage? {
        get {
            return gifFilterButton.imageForState(.Normal)
        }
        set(image) {
            gifFilterButton.setImage(image, forState: .Normal)
        }
    }
    
    @IBInspectable dynamic var textFilterButtonImage: UIImage? {
        get {
            return textFilterButton.imageForState(.Normal)
        }
        set(image) {
            textFilterButton.setImage(image, forState: .Normal)
        }
    }

    @IBInspectable dynamic var videoFilterButtonImage: UIImage? {
        get {
            return videoFilterButton.imageForState(.Normal)
        }
        set(image) {
            videoFilterButton.setImage(image, forState: .Normal)
        }
    }

    @IBInspectable dynamic var photoFilterButtonImage: UIImage? {
        get {
            return photoFilterButton.imageForState(.Normal)
        }
        set(image) {
            photoFilterButton.setImage(image, forState: .Normal)
        }
    }

    /**
        Set image for playback state
     */
    func setPlaybackButtonImageForState(state: Bool) {
        let imageName = state ? "PlaybackButtonImagePlaying" : "PlaybackButtonImagePaused"
        let image = UIImage(named: imageName)
        self.playbackButton.setImage(image, forState: .Normal)
    }
    
    /**
        Set the button image for the filter state.
     */
    func setFilterButtonImageForFilterType(filter: TweetType, forState state: Bool) {
        switch (filter) {
        case .Gif:
            let imageName = state ? "GifFilterImageOn" : "GifFilterImageOff"
            self.gifFilterButtonImage = UIImage(named: imageName)
        case .Text:
            let imageName = state ? "TextFilterImageOn" : "TextFilterImageOff"
            self.textFilterButtonImage = UIImage(named: imageName)
        case .Video:
            let imageName = state ? "VideoFilterImageOn" : "VideoFilterImageOff"
            self.videoFilterButtonImage = UIImage(named: imageName)
        case .Photo:
            let imageName = state ? "PhotoFilterImageOn" : "PhotoFilterImageOff"
            self.photoFilterButtonImage = UIImage(named: imageName)
        }
    }
    
    /**
        Actions
     */
    @IBAction func playbackButtonDidPress(sender: AnyObject) {
        self.delegate?.didTogglePlayback()
    }
    
    @IBAction func gifFilterButtonDidPress(sender: AnyObject) {
        self.delegate?.filterView(self, didToggleFilterForType: .Gif)
    }
    
    @IBAction func textFilterButtonDidPress(sender: AnyObject) {
        self.delegate?.filterView(self, didToggleFilterForType: .Text)
    }
    
    @IBAction func videoFilterButtonDidPress(sender: AnyObject) {
        self.delegate?.filterView(self, didToggleFilterForType: .Video)
    }
    
    @IBAction func photoFilterButtonDidPress(sender: AnyObject) {
        self.delegate?.filterView(self, didToggleFilterForType: .Photo)
    }
    
    /**
        Setup for nib
     */
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    func xibSetup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "FilterView", bundle: bundle)
        
        // Assumes UIView is top level and only object in CustomView.xib file
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        return view
    }
}
