//
//  ListView.swift
//  Pumba
//
//  Created by Marcel Breska on 25.04.23.
//

import SwiftUI
import CoreBluetooth

struct ListView: View {
    @EnvironmentObject var model: Model
    @State private var alertText = ""
    @State private var showingAlert = false
    
    var body: some View {
        NavigationView {
            List(model.peripherals, id: \.self) { peripheral in
                Button(action: {
                    model.connectPeripheral(peripheral: peripheral)
                    alertText = "connect \(peripheral.name)"
                }) {
                    Text(peripheral.name)
                }
            }
        }
        .alert(alertText, isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        }
        .navigationTitle("Bluetooth")
        .toolbar {
            Button("Refresh") {
                model.scanForDevices()
            }
        }
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView()
    }
}
