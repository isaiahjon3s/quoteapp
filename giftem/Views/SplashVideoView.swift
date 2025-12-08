//
//  SplashVideoView.swift
//  giftem
//
//  Created by Isaiah Jones on 12/8/25.
//

import SwiftUI
import AVKit

struct SplashVideoView: View {
    @State private var player: AVPlayer?
    
    var onFinished: () -> Void
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            if let player = player {
                VideoPlayerView(player: player)
                    .ignoresSafeArea()
            }
        }
        .onAppear {
            playVideo()
        }
    }
    
    private func playVideo() {
        guard let url = Bundle.main.url(forResource: "splash_animation", withExtension: "mp4") else {
            // Video not found, skip immediately
            onFinished()
            return
        }
        
        let avPlayer = AVPlayer(url: url)
        avPlayer.isMuted = true
        
        // When video ends, transition to app
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: avPlayer.currentItem,
            queue: .main
        ) { _ in
            onFinished()
        }
        
        self.player = avPlayer
        avPlayer.play()
    }
}

struct VideoPlayerView: UIViewControllerRepresentable {
    let player: AVPlayer
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = false
        controller.videoGravity = .resizeAspectFill
        controller.view.backgroundColor = .black
        controller.view.isUserInteractionEnabled = false
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}
}
