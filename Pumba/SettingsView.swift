//
//  Settings.swift
//  Pumba
//
//  Created by Marcel Breska on 20.09.24.
//

import SwiftUI
import CoreBluetooth

struct SettingsView: View {
    @EnvironmentObject var model: Model

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                SectionCard("Küche", systemImage: "fork.knife") {
                    ServoSlider(title: "Offen – Max", value: $model.openPosMaxKitchen, onCommit: model.updateServoSettings)
                    ServoSlider(title: "Offen – Halten", value: $model.openPosHoldKitchen, onCommit: model.updateServoSettings)
                    ServoSlider(title: "Zu – Max", value: $model.closedPosMaxKitchen, onCommit: model.updateServoSettings)
                    ServoSlider(title: "Zu – Halten", value: $model.closedPosHoldKitchen, onCommit: model.updateServoSettings)
                }

                SectionCard("Hängeschrank", systemImage: "cabinet.fill") {
                    ServoSlider(title: "Offen – Max", value: $model.openPosMaxCupboard, onCommit: model.updateServoSettingsCupboard)
                    ServoSlider(title: "Offen – Halten", value: $model.openPosHoldCupboard, onCommit: model.updateServoSettingsCupboard)
                    ServoSlider(title: "Zu – Max", value: $model.closedPosMaxCupboard, onCommit: model.updateServoSettingsCupboard)
                    ServoSlider(title: "Zu – Halten", value: $model.closedPosHoldCupboard, onCommit: model.updateServoSettingsCupboard)
                }

                Button(role: .destructive) {
                    model.disconnect()
                } label: {
                    Label("Verbindung trennen", systemImage: "wifi.slash")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.red.opacity(0.12), in: RoundedRectangle(cornerRadius: 14))
                        .foregroundStyle(.red)
                }
            }
            .padding(14)
        }
    }
}

/// A labelled servo-position slider (0–180°) that commits on release.
private struct ServoSlider: View {
    let title: String
    @Binding var value: Double
    let onCommit: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(Int(value))°")
                    .font(.subheadline.weight(.semibold))
                    .monospacedDigit()
            }
            Slider(value: $value, in: 0...180, step: 1, onEditingChanged: { editing in
                if !editing { onCommit() }
            })
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(Model(bluetoothService: BluetoothService()))
    }
}
