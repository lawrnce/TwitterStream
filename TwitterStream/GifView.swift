//
//  GifView.swift
//  TwitterStream
//
//  Created by lola on 5/3/16.
//  Copyright © 2016 LawrenceTran. All rights reserved.
//

import UIKit
import AVFoundation

/**
    Gifs on Twitter are encoded as mp4. Play it as a inline video
 */

class GifView: UIView {
    
    // Gif url
    var gifURL: NSURL! {
        didSet {
            setMp4WithURL(self.gifURL)
        }
    }
    
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    
    // MARK: - Setup

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Helper
    
    /**
        Sets up the gif.
     
        - Parameter url: The url of the gif.
     */
    private func setMp4WithURL(url: NSURL) {
        self.player = AVPlayer(URL: url)
        self.playerLayer = AVPlayerLayer(player: self.player)
        self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect
        self.playerLayer.frame = self.bounds
        self.layer.addSublayer(self.playerLayer)
    }
}
