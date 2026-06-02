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
            VStack {
                Text("Küche:").font(.title)
                
                VStack {
                    Text("Open Pos max: \(Int(model.openPosMaxKitchen))").padding()
                    Slider(value: $model.openPosMaxKitchen , in: 0.0...180.0, step: 1.0, onEditingChanged: { isEditing in
                        if (!isEditing) {
                            model.updateServoSettings()
                        }
                    })
                }
                
                VStack {
                    Text("Open Pos hold: \(Int(model.openPosHoldKitchen))").padding()
                    Slider(value: $model.openPosHoldKitchen , in: 0.0...180.0, step: 1.0, onEditingChanged: { isEditing in
                        if (!isEditing) {
                            model.updateServoSettings()
                        }
                    })
                }
                
                VStack {
                    Text("Closed Pos max: \(Int(model.closedPosMaxKitchen))").padding()
                    Slider(value: $model.closedPosMaxKitchen , in: 0.0...180.0, step: 1.0, onEditingChanged: { isEditing in
                        if (!isEditing) {
                            model.updateServoSettings()
                        }
                    })
                }
                
                VStack {
                    Text("Closed Pos hold: \(Int(model.closedPosHoldKitchen))").padding()
                    Slider(value: $model.closedPosHoldKitchen , in: 0.0...180.0, step: 1.0, onEditingChanged: { isEditing in
                        if (!isEditing) {
                            model.updateServoSettings()
                        }
                    })
                }
            }

            Text("Hängeschrank:").font(.title)
            VStack {
                Text("Open Pos max: \(Int(model.openPosMaxCupboard))").padding()
                Slider(value: $model.openPosMaxCupboard , in: 0.0...180.0, step: 1.0, onEditingChanged: { isEditing in
                    if (!isEditing) {
                        model.updateServoSettingsCupboard()
                    }
                })
            }
            
            VStack {
                Text("Open Pos hold: \(Int(model.openPosHoldCupboard))").padding()
                Slider(value: $model.openPosHoldCupboard , in: 0.0...180.0, step: 1.0, onEditingChanged: { isEditing in
                    if (!isEditing) {
                        model.updateServoSettingsCupboard()
                    }
                })
            }
            
            VStack {
                Text("Closed Pos max: \(Int(model.closedPosMaxCupboard))").padding()
                Slider(value: $model.closedPosMaxCupboard , in: 0.0...180.0, step: 1.0, onEditingChanged: { isEditing in
                    if (!isEditing) {
                        model.updateServoSettingsCupboard()
                    }
                })
            }
            
            VStack {
                Text("Closed Pos hold: \(Int(model.closedPosHoldCupboard))").padding()
                Slider(value: $model.closedPosHoldCupboard , in: 0.0...180.0, step: 1.0, onEditingChanged: { isEditing in
                    if (!isEditing) {
                        model.updateServoSettingsCupboard()
                    }
                })
            }
        }
    }
}


struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(Model(bluetoothService: BluetoothService()))
    }
}
