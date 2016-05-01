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
    func filterView(filterView: FilterView, didToggleFilter filter: TweetFilter)
}

@IBDesignable class FilterView: UIView {

    var delegate: FilterViewDelegate?
    
    // nib properties
    var view: UIView!
    
    // outlets
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var videoFilterButton: UIButton!
    @IBOutlet weak var gifFilterButton: UIButton!
    @IBOutlet weak var photoFilterButton: UIButton!
    
    /**
        Set the button image for the filter state.
     */
    func setImageForFilter(filter: TweetFilter, forState state: Bool) {
        switch (filter) {
            case .Gif:
                let imageName = state ? "GifFilterImageOn" : "GifFilterImageOff"
                let image = UIImage(named: imageName)
                self.gifFilterButton.setImage(image, forState: .Normal)
            
            case .Video:
                let imageName = state ? "VideoFilterImageOn" : "VideoFilterImageOff"
                let image = UIImage(named: imageName)
                self.videoFilterButton.setImage(image, forState: .Normal)
            
            case .Photo:
                let imageName = state ? "PhotoFilterImageOn" : "PhotoFilterImageOff"
                let image = UIImage(named: imageName)
                self.photoFilterButton.setImage(image, forState: .Normal)
        }
    }
    
    /**
        Actions
     */
    @IBAction func gifFilterDidPress(sender: AnyObject) {
        self.delegate?.filterView(self, didToggleFilter: .Gif)
    }
    
    @IBAction func videoFilterDidPress(sender: AnyObject) {
        self.delegate?.filterView(self, didToggleFilter: .Video)
    }
    
    @IBAction func photoFilterDidPress(sender: AnyObject) {
        self.delegate?.filterView(self, didToggleFilter: .Photo)
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
