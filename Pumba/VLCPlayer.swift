//
//  VLCPlayer.swift
//  Pumba
//
//  Created by Marcel Breska on 22.09.24.
//

import SwiftUI
import UIKit
import MediaPlayer

struct VLCPlayerView: UIViewControllerRepresentable {
    var rtspUrl: String

    func makeUIViewController(context: Context) -> UIViewController {
        return VLCPlayerViewController(rtspUrl: rtspUrl)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Handle updates if necessary
    }
}

class VLCPlayerViewController: UIViewController, VLCMediaPlayerDelegate {
    var mediaPlayer: VLCMediaPlayer?
    var rtspUrl: String

    init(rtspUrl: String) {
        self.rtspUrl = rtspUrl
        super.init(nibName: nil, bundle: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(stopStream), name: .stopStream, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(startStream), name: .startStream, object: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        mediaPlayer = VLCMediaPlayer()
        DispatchQueue.main.async {
            self.mediaPlayer?.drawable = self.view  // Ensure drawable is set on the main thread
        }
//        mediaPlayer?.drawable = self.view
        mediaPlayer?.delegate = self  // Set delegate to receive events

        startStream()
    }
    
    @objc func startStream() {
        if let encodedURL = rtspUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let url = URL(string: encodedURL) {
            let media = VLCMedia(url: url)
            media.addOption(":rtsp-tcp")
//            media.addOption(":network-caching=500")
//            media.addOption(":no-hw-decoding")
            media.addOption(":rtsp-reordering=0")

            mediaPlayer?.media = media
            mediaPlayer?.play()
        } else {
            print("Invalid RTSP URL")
        }
    }
    
    @objc func stopStream() {
        mediaPlayer?.stop()
    }

    func mediaPlayerStateChanged(_ aNotification: Notification) {
        if mediaPlayer?.state == .error {
            print("Error in media player")
        } else {
            print("Player state changed: \(String(describing: mediaPlayer?.state))")
        }
    }

    func mediaPlayerTimeChanged(_ aNotification: Notification) {
        print("Player time: \(String(describing: mediaPlayer?.time))")
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        DispatchQueue.main.async {
            self.mediaPlayer?.drawable = self.view  // Ensure drawable is set on the main thread
        }
//        mediaPlayer?.drawable = self.view
    }

    deinit {
        mediaPlayer?.stop()
        mediaPlayer = nil
        NotificationCenter.default.removeObserver(self)
    }
}
