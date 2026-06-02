//
//  ContentView.swift
//  Pumba
//
//  Created by Marcel Breska on 24.04.23.
//

import SwiftUI
import CoreBluetooth

struct ContentView: View {
    @StateObject private var model = Model(bluetoothService: BluetoothService())
    @Environment(\.scenePhase) var scenePhase

    /// DEBUG: show the main UI without a BLE connection so the app can be
    /// inspected on-device. Set back to `false` before shipping.
    private let forceShowMainUI = false

    var body: some View {
        NavigationView {
            HStack {
                if forceShowMainUI || model.isConnected {
                    TabView {
                        DetailView()
                             .tabItem {
                                 Image(systemName: "house.fill")
                                 Text("Home")
                             }

                        SettingsView()
                             .tabItem {
                                 Image(systemName: "gearshape")
                                 Text("Einstellungen")
                             }
                     }

                } else {
                    ListView()
                }
            }
        }
        .environmentObject(model)
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                model.scanForDevices()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

