//
//  WasteWaterCameraView.swift
//  Pumba
//
//  Created by Marcel Breska on 22.09.24.
//
import SwiftUI

/// RTSP URL for the sewage camera. The authority (`user:pass@host:port/path`)
/// is injected at build time from `Secrets.xcconfig` via the
/// `CameraRTSPAuthority` Info.plist key, so no credentials live in source.
let SEWAGE_CAMERA_RTSP_URL: String = {
    guard let authority = Bundle.main.object(forInfoDictionaryKey: "CameraRTSPAuthority") as? String,
          !authority.isEmpty else {
        return ""
    }
    return "rtsp://\(authority)"
}()

struct WasteWaterCameraView: View {
    @Environment(\.scenePhase) private var scenePhase  // Track app lifecycle
    @EnvironmentObject var model: Model

    var body: some View {
        ZStack {
            VLCPlayerView(rtspUrl: SEWAGE_CAMERA_RTSP_URL)
                .onChange(of: scenePhase) { newPhase in
                    if newPhase == .background {
                        // App is going to the background, stop the stream
                        NotificationCenter.default.post(name: .stopStream, object: nil)
                    } else if newPhase == .active {
                        // App is coming to the foreground, restart the stream
                        NotificationCenter.default.post(name: .startStream, object: nil)
                    }
                }
            VStack {
                Spacer()  // Pushes content to the bottom
                RelayButton(action: {
                    model.updateSewageValve(isOn: !model.isSewageOpen)
                }, isOn: $model.isSewageOpen, onIcon: "pipe.and.drop.fill", offIcon: "pipe.and.drop.fill", accentColor: .cyan)
                    .padding(.bottom, 20)  // Optional padding to give space from the bottom edge
            }
        }

    }
}

extension Notification.Name {
    static let stopStream = Notification.Name("stopStream")
    static let startStream = Notification.Name("startStream")
}
