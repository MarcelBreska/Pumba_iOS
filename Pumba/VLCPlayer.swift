//
//  VLCPlayer.swift
//  Pumba
//
//  Created by Marcel Breska on 22.09.24.
//

import SwiftUI
import UIKit

struct VLCPlayerView: UIViewControllerRepresentable {
    var rtspUrl: String

    func makeUIViewController(context: Context) -> UIViewController {
        return VLCPlayerViewController(rtspUrl: rtspUrl)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Nothing to update; the controller owns the player for its lifetime.
    }
}

class VLCPlayerViewController: UIViewController, VLCMediaPlayerDelegate {
    private var mediaPlayer: VLCMediaPlayer?
    private let rtspUrl: String
    /// Attach the drawable exactly once, after the view has a real size.
    /// Re-assigning it on every layout pass makes VLC re-init its output and
    /// the feed never renders.
    private var didAttachDrawable = false

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
        view.backgroundColor = .black
        mediaPlayer = VLCMediaPlayer()
        mediaPlayer?.delegate = self
        startStream()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard !didAttachDrawable, view.bounds.width > 0, view.bounds.height > 0 else { return }
        didAttachDrawable = true
        mediaPlayer?.drawable = view
    }

    @objc func startStream() {
        guard let encodedURL = rtspUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encodedURL) else { return }
        let media = VLCMedia(url: url)
        media.addOption(":rtsp-tcp")
        media.addOption(":rtsp-reordering=0")
        mediaPlayer?.media = media
        mediaPlayer?.play()
    }

    @objc func stopStream() {
        mediaPlayer?.stop()
    }

    deinit {
        mediaPlayer?.stop()
        mediaPlayer = nil
        NotificationCenter.default.removeObserver(self)
    }
}
