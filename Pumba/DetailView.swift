//
//  DetailView.swift
//  Pumba
//
//  Created by Marcel Breska on 25.04.23.
//

import SwiftUI
import CoreBluetooth

struct DetailView: View {
    @EnvironmentObject var model: Model
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @State private var showCamera = false

    /// Landscape on iPhone reports a compact height — use it to switch to a
    /// two-column dashboard instead of one narrow column.
    private var isLandscape: Bool { verticalSizeClass == .compact }

    var body: some View {
        ScrollView {
            Group {
                if isLandscape {
                    landscapeLayout
                } else {
                    portraitLayout
                }
            }
            .padding(14)
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraFullScreen()
                .environmentObject(model)
        }
    }

    private var portraitLayout: some View {
        VStack(spacing: 14) {
            ControlsCard()
            EnergyCard()
            HStack(spacing: 14) {
                CameraPreviewCard(showCamera: $showCamera)
                TiltCard()
            }
            BatteryCard()
            SolarBoosterCard()
            WaterCard()
        }
    }

    private var landscapeLayout: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(spacing: 14) {
                ControlsCard()
                EnergyCard()
                WaterCard()
            }
            VStack(spacing: 14) {
                HStack(spacing: 14) {
                    CameraPreviewCard(showCamera: $showCamera)
                    TiltCard()
                }
                BatteryCard()
                SolarBoosterCard()
            }
        }
    }
}

// MARK: - Controls

struct ControlsCard: View {
    @EnvironmentObject var model: Model

    var body: some View {
        SectionCard("Steuerung", systemImage: "switch.2") {
            HStack(spacing: 10) {
                ControlToggle(title: "Inverter", icon: "bolt.fill", color: .yellow, isOn: $model.isInverterOn) {
                    model.updateInverter(isOn: !model.isInverterOn)
                }
                ControlToggle(title: "Pumpe", icon: "drop.fill", color: .cyan, isOn: $model.isWaterpumpOn) {
                    model.updateWaterpump(isOn: !model.isWaterpumpOn)
                }
                ControlToggle(title: "Küche", icon: model.isLocked ? "lock.fill" : "lock.open.fill", color: .pink, isOn: $model.isLocked) {
                    model.updateKitchenLock(isLocked: !model.isLocked)
                }
                ControlToggle(title: "Heizung", icon: "thermometer.medium", color: .orange, isOn: $model.isTankHeaterOn) {
                    model.updateTankHeater(isOn: !model.isTankHeaterOn)
                }
                ControlToggle(title: "Abwasser", icon: "pipe.and.drop.fill", color: .teal, isOn: $model.isSewageOpen) {
                    model.updateSewageValve(isOn: !model.isSewageOpen)
                }
            }
        }
    }
}

/// Compact modern relay toggle: tinted/filled when on, subtle when off.
struct ControlToggle: View {
    let title: String
    let icon: String
    let color: Color
    @Binding var isOn: Bool
    let action: () -> Void

    var body: some View {
        Button {
            action()
            isOn.toggle()
        } label: {
            VStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(isOn ? AnyShapeStyle(color.gradient) : AnyShapeStyle(Color(.tertiarySystemFill)))
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(isOn ? .white : .secondary)
                }
                .frame(height: 54)
                .shadow(color: isOn ? color.opacity(0.4) : .clear, radius: 7, y: 2)

                Text(title)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .animation(.snappy(duration: 0.2), value: isOn)
    }
}

// MARK: - Energy

struct EnergyCard: View {
    var body: some View {
        SectionCard("Energie", systemImage: "bolt.fill") {
            EnergyView()
                .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Camera preview

struct CameraPreviewCard: View {
    @Binding var showCamera: Bool

    var body: some View {
        SectionCard("Kamera", systemImage: "video.fill") {
            ZStack {
                RoundedRectangle(cornerRadius: 12).fill(Color.black)

                // Only stream the preview while the fullscreen isn't open, so
                // there's never more than one RTSP connection at a time.
                if !showCamera {
                    VLCPlayerView(rtspUrl: SEWAGE_CAMERA_RTSP_URL)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    Image(systemName: "video.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.white.opacity(0.35))
                }

                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                            .font(.footnote.bold())
                            .foregroundStyle(.white)
                            .padding(7)
                            .background(.black.opacity(0.45), in: Circle())
                            .padding(8)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 150)
            .contentShape(Rectangle())
            .onTapGesture { showCamera = true }
        }
    }
}

/// Fullscreen camera (live feed + sewage-valve button) with a close button.
struct CameraFullScreen: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        WasteWaterCameraView()
            .overlay(alignment: .topTrailing) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.largeTitle)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.white, .black.opacity(0.5))
                        .padding()
                }
            }
    }
}

// MARK: - Tilt (IMU) bubble level

struct TiltCard: View {
    @EnvironmentObject var model: Model

    var body: some View {
        SectionCard("Neigung", systemImage: "gyroscope") {
            BubbleLevel(ax: model.imuData.ax, ay: model.imuData.ay)
                .frame(maxWidth: .infinity)
                .frame(height: 150)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(LinearGradient(colors: [Color(white: 0.12), Color(white: 0.04)],
                                             startPoint: .top, endPoint: .bottom))
                )
        }
    }
}

/// A clean bubble-level: concentric rings + crosshair + a glowing bubble that
/// shifts green→red the further from level it is.
struct BubbleLevel: View {
    let ax: Float
    let ay: Float

    var body: some View {
        GeometryReader { geo in
            let side = min(geo.size.width, geo.size.height)
            let maxR = side / 2 - 16
            let scale: CGFloat = 1000
            let raw = CGPoint(x: CGFloat(ay) * scale, y: CGFloat(ax) * scale)
            let mag = max(hypot(raw.x, raw.y), 0.0001)
            let clamped = mag > maxR
                ? CGPoint(x: raw.x / mag * maxR, y: raw.y / mag * maxR)
                : raw
            let level = min(mag / maxR, 1)
            let bubbleColor = Color(hue: (1 - level) * 0.33, saturation: 0.85, brightness: 0.95)

            ZStack {
                // crosshair
                Rectangle().fill(.white.opacity(0.08)).frame(width: side, height: 1)
                Rectangle().fill(.white.opacity(0.08)).frame(width: 1, height: side)

                // concentric target rings
                Circle().stroke(.white.opacity(0.22), lineWidth: 1.5).frame(width: maxR * 2)
                Circle().stroke(.white.opacity(0.16), lineWidth: 1).frame(width: maxR * 1.3)
                Circle().stroke(.white.opacity(0.12), lineWidth: 1).frame(width: maxR * 0.6)

                // center marker
                Circle().fill(.white.opacity(0.35)).frame(width: 6, height: 6)

                // moving bubble
                Circle()
                    .fill(bubbleColor)
                    .frame(width: 26, height: 26)
                    .overlay(Circle().stroke(.white.opacity(0.85), lineWidth: 1.5))
                    .shadow(color: bubbleColor.opacity(0.8), radius: 8)
                    .offset(x: clamped.x, y: clamped.y)
                    .animation(.easeOut(duration: 0.18), value: clamped)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView()
            .environmentObject(Model(bluetoothService: BluetoothService()))
    }
}
