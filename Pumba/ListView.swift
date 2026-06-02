//
//  ListView.swift
//  Pumba
//
//  Created by Marcel Breska on 25.04.23.
//

import SwiftUI
import CoreBluetooth

/// Shown until connected to the Pumba Zentrale. Scans and auto-connects in the
/// background; manual device selection is one tap away if needed.
struct ListView: View {
    @EnvironmentObject var model: Model
    @State private var showDeviceList = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(.systemBackground), Color.accentColor.opacity(0.10)],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer()

                scanningHero

                VStack(spacing: 8) {
                    Text(model.autoConnect ? "Suche Pumba Zentrale" : "Nicht verbunden")
                        .font(.title2.bold())
                    if model.autoConnect {
                        HStack(spacing: 8) {
                            SwiftUI.ProgressView()
                                .controlSize(.small)
                            Text("Verbinde automatisch …")
                                .foregroundStyle(.secondary)
                        }
                        .font(.subheadline)
                    } else {
                        Text("Verbindung getrennt – wähle ein Gerät")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                VStack(spacing: 12) {
                    if !model.autoConnect {
                        Button {
                            model.reconnect()
                        } label: {
                            Label("Verbinden", systemImage: "antenna.radiowaves.left.and.right")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.accentColor.gradient, in: RoundedRectangle(cornerRadius: 14))
                                .foregroundStyle(.white)
                        }
                    }

                    Button {
                        showDeviceList = true
                    } label: {
                        Label("Gerät manuell wählen", systemImage: "list.bullet")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(Color.accentColor)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 22)
                            .background(Color.accentColor.opacity(0.12), in: Capsule())
                    }
                }
            }
            .padding(24)
        }
        .navigationBarHidden(true)
        .onAppear {
            model.scanForDevices()
        }
        .sheet(isPresented: $showDeviceList) {
            DevicePickerSheet()
                .environmentObject(model)
        }
    }

    // MARK: - Funky animated radar hero

    private let orbitColors: [Color] = [.cyan, .blue, .purple, .pink, .orange, .green]

    private var scanningHero: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            ZStack {
                radarSweep(t)
                pulseRings(t)
                orbitingDots(t)
                centerOrb(t)
            }
            .frame(width: 230, height: 230)
        }
        .frame(height: 230)
    }

    private func radarSweep(_ t: Double) -> some View {
        AngularGradient(
            colors: [.purple, .blue, .cyan, .green, .yellow, .orange, .pink, .purple],
            center: .center
        )
        .mask(Circle().strokeBorder(lineWidth: 16))
        .frame(width: 210, height: 210)
        .rotationEffect(.degrees(t * 75))
        .blur(radius: 3)
        .opacity(0.8)
    }

    private func pulseRings(_ t: Double) -> some View {
        ForEach(0..<3, id: \.self) { i in
            PulseRing(t: t, index: i)
        }
    }

    private func orbitingDots(_ t: Double) -> some View {
        ForEach(0..<orbitColors.count, id: \.self) { i in
            OrbitDot(t: t, color: orbitColors[i], index: i, count: orbitColors.count)
        }
    }

    private func centerOrb(_ t: Double) -> some View {
        let breathe: CGFloat = 1.0 + 0.06 * CGFloat(sin(t * 2))
        return ZStack {
            Circle()
                .fill(LinearGradient(colors: [.indigo, .cyan],
                                     startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 122, height: 122)
                .shadow(color: .cyan.opacity(0.6), radius: 22)
                .overlay(Circle().stroke(.white.opacity(0.25), lineWidth: 1))

            Image(systemName: "antenna.radiowaves.left.and.right")
                .font(.system(size: 46, weight: .bold))
                .foregroundStyle(.white)
        }
        .scaleEffect(breathe)
    }
}

/// One expanding radar pulse ring.
private struct PulseRing: View {
    let t: Double
    let index: Int

    var body: some View {
        let phase: Double = ((t / 2.2) + Double(index) / 3.0).truncatingRemainder(dividingBy: 1.0)
        let scale: CGFloat = 1.0 + CGFloat(phase) * 1.6
        let opacity: Double = (1.0 - phase) * 0.55
        return Circle()
            .stroke(Color.cyan.opacity(opacity), lineWidth: 2)
            .frame(width: 130, height: 130)
            .scaleEffect(scale)
    }
}

/// One orbiting dot circling the center orb.
private struct OrbitDot: View {
    let t: Double
    let color: Color
    let index: Int
    let count: Int

    var body: some View {
        let step: Double = (Double.pi * 2.0) / Double(count)
        let a: Double = t * 1.3 + Double(index) * step
        let dx: CGFloat = CGFloat(cos(a)) * 98.0
        let dy: CGFloat = CGFloat(sin(a)) * 98.0
        return Circle()
            .fill(color)
            .frame(width: 13, height: 13)
            .shadow(color: color.opacity(0.8), radius: 5)
            .offset(x: dx, y: dy)
    }
}

/// Manual device picker. Hides the (often hundreds of) unnamed devices by
/// default; named devices like "Pumba_Zentrale" are what you actually want.
struct DevicePickerSheet: View {
    @EnvironmentObject var model: Model
    @Environment(\.dismiss) private var dismiss
    @State private var showAll = false

    private var namedDevices: [Peripheral] {
        model.peripherals.filter { $0.name != "unnamed device" }
    }

    private var devices: [Peripheral] {
        showAll ? model.peripherals : namedDevices
    }

    private var hiddenCount: Int {
        model.peripherals.count - namedDevices.count
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    if devices.isEmpty {
                        HStack(spacing: 10) {
                            SwiftUI.ProgressView().controlSize(.small)
                            Text("Suche Geräte …")
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        ForEach(devices) { peripheral in
                            Button {
                                model.connectPeripheral(peripheral: peripheral)
                                dismiss()
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: "dot.radiowaves.left.and.right")
                                        .foregroundStyle(Color.accentColor)
                                    Text(peripheral.name)
                                        .foregroundStyle(.primary)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption.bold())
                                        .foregroundStyle(.tertiary)
                                }
                            }
                        }
                    }
                } footer: {
                    if !showAll && hiddenCount > 0 {
                        Text("\(hiddenCount) unbenannte Geräte ausgeblendet")
                    }
                }

                if hiddenCount > 0 {
                    Toggle("Alle Geräte anzeigen", isOn: $showAll)
                }
            }
            .navigationTitle("Gerät wählen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Erneut suchen") { model.scanForDevices() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fertig") { dismiss() }
                }
            }
        }
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView()
            .environmentObject(Model(bluetoothService: BluetoothService()))
    }
}
