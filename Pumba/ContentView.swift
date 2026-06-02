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
    @State private var selectedTab = Tab.home

    /// DEBUG: show the main UI without a BLE connection so the app can be
    /// inspected on-device. Set back to `false` before shipping.
    private let forceShowMainUI = false

    private enum Tab: Hashable { case home, settings, disconnect }

    var body: some View {
        NavigationView {
            HStack {
                if forceShowMainUI || model.isConnected {
                    TabView(selection: $selectedTab) {
                        DetailView()
                            .tag(Tab.home)
                            .tabItem {
                                Image(systemName: "house.fill")
                                Text("Home")
                            }

                        SettingsView()
                            .tag(Tab.settings)
                            .tabItem {
                                Image(systemName: "gearshape")
                                Text("Einstellungen")
                            }

                        // Acts as a button: tapping it disconnects (see onChange).
                        Color.clear
                            .tag(Tab.disconnect)
                            .tabItem {
                                Image(systemName: "wifi.slash")
                                Text("Trennen")
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
        .onChange(of: selectedTab) { newValue in
            if newValue == .disconnect {
                model.disconnect()
                selectedTab = .home
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

