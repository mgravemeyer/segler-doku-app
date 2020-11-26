//
//  AVPlayer.swift
//  Segler
//
//  Created by Maximilian Gravemeyer on 26.11.20.
//  Copyright © 2020 Maximilian Gravemeyer. All rights reserved.
//

import UIKit
import SwiftUI
import AVKit

struct AVPlayerView: UIViewControllerRepresentable {

    @Binding var videoURL: URL?
    
    var frameWidth: CGFloat
    var frameHeight: CGFloat
    var rotation: Double

    private var player: AVPlayer {
        return AVPlayer(url: videoURL!)
    }

    func updateUIViewController(_ playerController: AVPlayerViewController, context: Context) {
        playerController.showsPlaybackControls = true
        playerController.player = player
        playerController.entersFullScreenWhenPlaybackBegins = true
        playerController.player?.play()
        playerController.view.transform = CGAffineTransform(rotationAngle: CGFloat((rotation * Double.pi)/180))
        playerController.view.frame = CGRect(x: 0, y: 0, width: (frameWidth), height: (frameHeight))
    }

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        return AVPlayerViewController()
    }
}
