//
//  GifView.swift
//  TwitterStream
//
//  Created by lola on 5/3/16.
//  Copyright © 2016 LawrenceTran. All rights reserved.
//

import UIKit
import AVFoundation

class GifView: UIView {
    
    var gifURL: NSURL! {
        didSet {
            setMp4WithURL(self.gifURL)
        }
    }
    
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setMp4WithURL(url: NSURL) {
        self.player = AVPlayer(URL: url)
        self.playerLayer = AVPlayerLayer(player: self.player)
        self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect
        self.playerLayer.frame = self.bounds
        self.layer.addSublayer(self.playerLayer)
    }
    
    deinit {
        
    }
}
