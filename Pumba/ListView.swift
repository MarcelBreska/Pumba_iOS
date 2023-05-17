//
//  ListView.swift
//  Pumba
//
//  Created by Marcel Breska on 25.04.23.
//

import SwiftUI
import CoreBluetooth

struct ListView: View {
    
    @EnvironmentObject var viewModel: BluetoothViewModel
    
    var body: some View {
        NavigationView {
            List(viewModel.peripherals, id: \.self) { peripheral in
                Button(action: {
                    viewModel.connectPeripheral(peripheral)
                    print("test")
                }) {
                    Text(peripheral.name ?? "unnamed device")
                }
                
            }
        }
        .navigationTitle("Bluetooth")
        .toolbar {
            Button("Refresh") {
                viewModel.scanForDevices()
            }
        }
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView()
    }
}
