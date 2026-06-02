//
//  EnergyView.swift
//  Pumba
//
//  Created by Marcel Breska on 22.06.23.
//

import SwiftUI

struct EnergyView: View {
    @EnvironmentObject var model: Model
    
    let batteryColors = [
        UIColor(red: 1, green: 0.239, blue: 0, alpha: 1),
        UIColor(red: 1, green: 0.569, blue: 0, alpha: 1),
        UIColor(red: 1, green: 0.918, blue: 0, alpha: 1),
        UIColor(red: 0.776, green: 1, blue: 0, alpha: 1),
        UIColor(red: 0.463, green: 1, blue: 0.012, alpha: 1)
    ]
    
    var batteryIcon: String {
        switch model.soc {
        case 80...:
            return "battery.100"
        case 60...:
            return "battery.75"
        case 40...:
            return "battery.50"
        case 20...:
            return "battery.25"
        default:
            return "battery.0"
        }
    }
    
    var currentPowerUsage: CGFloat {
        -(CGFloat(model.veDirectData1.power) - model.solarW - model.boosterW)
    }
    
    var body: some View {
        VStack {
            HStack(spacing: 15) {
                
                ProgressView(
                    color: Color(batteryColors.intermediate(percentage: model.soc / 100)),
                    icon: batteryIcon,
                    maxValue: 100,
                    value: model.soc,
                    text: "\(Int(model.soc.isNaN ? 0 : model.soc))%"
                )
                .frame(width: 64, height: 120)
                
                ProgressView(
                    color: .pink,
                    icon: "bolt.fill",
                    maxValue: 3000,
                    value: currentPowerUsage,
                    text: "\(Int(currentPowerUsage.isNaN ? 0 : currentPowerUsage))W"
                )
                .frame(width: 50, height: 120)
                
                ProgressView(
                    color: .yellow,
                    icon: "sun.max.fill",
                    maxValue: 600,
                    value: model.solarW,
                    text: "\(Int(model.solarW.isNaN ? 0 : model.solarW))W"
                )
                .frame(width: 50, height: 120)
                
                ProgressView(
                    color: .cyan,
                    icon: "engine.combustion.fill",
                    maxValue: 600,
                    value: model.boosterW,
                    text: "\(Int(model.boosterW.isNaN ? 0 : model.boosterW))W"
                )
                .frame(width: 50, height: 120)
            }
        }
    }
}

struct EnergyView_Previews: PreviewProvider {
    static var previews: some View {
        EnergyView()
            .environmentObject(Model(bluetoothService: BluetoothService()))
    }
}

extension Array where Element: UIColor {
    func intermediate(percentage: CGFloat) -> UIColor {
        switch percentage {
        case 0: return first ?? .clear
        case 1: return last ?? .clear
        default:
            let approxIndex = percentage / (1 / CGFloat(count - 1))
            let firstIndex = Int(approxIndex.rounded(.down))
            let secondIndex = Int(approxIndex.rounded(.up))
            let fallbackIndex = Int(approxIndex.rounded())

            let firstColor = self[firstIndex]
            let secondColor = self[secondIndex]
            let fallbackColor = self[fallbackIndex]

            var (r1, g1, b1, a1): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
            var (r2, g2, b2, a2): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
            guard firstColor.getRed(&r1, green: &g1, blue: &b1, alpha: &a1) else { return fallbackColor }
            guard secondColor.getRed(&r2, green: &g2, blue: &b2, alpha: &a2) else { return fallbackColor }

            let intermediatePercentage = approxIndex - CGFloat(firstIndex)
            return UIColor(red: CGFloat(r1 + (r2 - r1) * intermediatePercentage),
                           green: CGFloat(g1 + (g2 - g1) * intermediatePercentage),
                           blue: CGFloat(b1 + (b2 - b1) * intermediatePercentage),
                           alpha: CGFloat(a1 + (a2 - a1) * intermediatePercentage))
        }
    }
}

