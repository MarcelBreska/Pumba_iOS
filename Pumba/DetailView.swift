//
//  DetailView.swift
//  Pumba
//
//  Created by Marcel Breska on 25.04.23.
//

import SwiftUI
import CoreBluetooth

struct DetailView: View {
    @EnvironmentObject var viewModel: BluetoothViewModel
    @State private var kitchenServoPos = 70.0

    
    var body: some View {
        ScrollView {
            VStack {
                VStack {
                    Toggle("230V", isOn: Binding(
                        get: { viewModel.isInverterOn },
                        set: { newValue in
                            viewModel.updateInverter(isOn: newValue)
                        }
                    )
                    )
                    
                    Toggle("Wasserpumpe", isOn: Binding(
                        get: { viewModel.waterpumpIsOn },
                        set: { newValue in
                            viewModel.updateWaterpump(isOn: newValue)
                        }
                    )
                    )
                    
                    Toggle("Abwasserheizung", isOn: Binding(
                        get: { viewModel.tankHeaterIsOn },
                        set: { newValue in
                            viewModel.updateTankHeater(isOn: newValue)
                        }
                    )
                    )
                    
                    Toggle("Tankentleerung", isOn: Binding(
                        get: { viewModel.isSewageValveOpen },
                        set: { newValue in
                            viewModel.updateSewageValve(isOn: newValue)
                        }
                    )
                    )
                    
                    Toggle("Schrankverriegelung", isOn: Binding(
                        get: { viewModel.isLocked },
                        set: { newValue in
                            viewModel.updateKitchenLock(isLocked: newValue)
                        }
                    )
                    )
                    
                    HStack {
                        Text("\(kitchenServoPos)").padding()
                        Slider(value: $kitchenServoPos , in: 0.0...120.0, step: 1.0, onEditingChanged: {_ in
                            viewModel.updateServoPos(pos: kitchenServoPos)
                        })
                    }
                }
                .padding()
                .disabled(!viewModel.isDataReady)
                
                VStack {
                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.2), lineWidth: 4)
                            .frame(width: 200, height: 200)
                        Circle()
                            .stroke(Color.blue.opacity(0.5), lineWidth: 8)
                            .frame(width: 150, height: 150)
                            .rotationEffect(.degrees(45))
                        Circle()
                            .stroke(Color.purple.opacity(0.8), lineWidth: 10)
                            .frame(width: 100, height: 100)
                            .rotationEffect(.degrees(30))
                        ZStack {
                            Circle()
                                .fill(Color(UIColor.systemTeal))
                                .frame(width: 20, height: 20)
                                .shadow(color: Color(UIColor.systemTeal).opacity(0.5), radius: 40, x: 0, y: 0)
                            Circle()
                                .fill(Color(UIColor.systemTeal))
                                .frame(width: 40, height: 40)
                                .opacity(0.5)
                                .blur(radius: 5)
                            
                        }
                        .offset(x: CGFloat(viewModel.accData.ax) * 100, y: CGFloat(viewModel.accData.ay) * 100)
                    }
                    .aspectRatio(1, contentMode: .fit)
                    .padding(40)
                    .background(Color.black.edgesIgnoringSafeArea(.all))
                
                    VStack {
                        Text("Warmwasserkalibrierungsfaktor")
                        HStack {
                            Text("\(viewModel.flowSettings.warmWaterFlowCalibrationFactor)").padding()
                            Slider(value: $viewModel.flowSettings.warmWaterFlowCalibrationFactor , in: 0.0...10.0, step: 0.01, onEditingChanged: {_ in
                                viewModel.updateADCSettingsData()
                            })
                        }
                    }
                    
                    VStack {
                        HStack {
                            Text("Batterie Spannung:")
                            Spacer()
                            Text(String(format: "%.2fV", viewModel.adcData.batteryV))
                        }
                        Text("VEDirect:")
                        HStack {
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text(String(format: "%.2fW", viewModel.veDirectData.power))
                                Text(String(format: "%.2f%%", viewModel.veDirectData.soc))
                            }
                        }
                        Text("Solar:")
                        HStack {
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text(String(format: "%.2fV", viewModel.adcData.solarV))
                                Text(String(format: "%.2fA", viewModel.adcData.solarA))
                                Text(String(format: "%.2fAh", viewModel.adcData.solarAh))
                                Text(String(format: "%.2fW", viewModel.adcData.solarW))
                                Text(String(format: "%.2fWh", viewModel.adcData.solarWh))
                                Text("Total: \(String(format: "%.2fWh", viewModel.adcData.solarWh))")
                            }
                        }
                        
                        Text("Booster:")
                        HStack {
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text(String(format: "%.2fV", viewModel.adcData.batteryV))
                                Text(String(format: "%.2fA", viewModel.adcData.boosterA))
                                Text(String(format: "%.2fAh", viewModel.adcData.boosterAh))
                                Text(String(format: "%.2fW", viewModel.adcData.boosterW))
                                Text(String(format: "%.2fWh", viewModel.adcData.boosterWh))
                                Text("Total: \(String(format: "%.2fWh", viewModel.adcData.boosterWh))")
                            }
                        }
                        
                        HStack {
                            Text("Wasserdruck:")
                            Spacer()
                            Text(String(format: "%.2fbar", (viewModel.adcData.waterPressureV - 0.5) * 10.0 / 4.5))
                        }
                        VStack {
                            HStack {
                                Text("Abwassertemperatur:")
                                Spacer()
                                Text(String(format: "%.2f°C", viewModel.sewageTemperature))
                            }
                            
                            HStack {
                                VStack {
                                    Text("Warmwasser:")
                                    Text("FlowRate: \(String(format: "%.2fl/Min", viewModel.waterFlowData.warmFlow))")
                                    Text("Gesamt: \(String(format: "%.2fl", viewModel.waterFlowData.warmTotal))")
                                }
                            }
                            
                            HStack {
                                VStack {
                                    Text("Wasserfilter:")
                                    Text("FlowRate: \(String(format: "%.2fl/Min", viewModel.waterFlowData.filterFlow))")
                                    Text("Gesamt: \(String(format: "%.2fl", viewModel.waterFlowData.filterTotal))")
                                }
                            }
                        }
                    }
                }
            }.padding()
        }
    }
}

//struct DetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        DetailView()
//    }
//}
