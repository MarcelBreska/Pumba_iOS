//
//  DataView.swift
//  Pumba
//
//  Created by Marcel Breska on 20.09.24.
//

import SwiftUI
import CoreBluetooth

struct DataView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                BatteryCard()
                SolarBoosterCard()
                WaterCard()
                SensorCard()
                BatteryDetailsCard()
            }
            .padding()
        }
    }
}

// MARK: - Data cards (reused on Home and in the Daten tab)

struct BatteryCard: View {
    @EnvironmentObject var model: Model

    var body: some View {
        let d1 = model.veDirectData1
        let d2 = model.veDirectData2
        SectionCard("Batterie", systemImage: "minus.plus.batteryblock.fill") {
            MetricRow("Spannung", String(format: "%.2f V", d1.voltage))
            MetricRow("Strom", String(format: "%.2f A", d1.current))
            MetricRow("Leistung", "\(d1.power) W")
            MetricRow("Ladezustand", String(format: "%.0f %%", d2.soc))
            MetricRow("Temperatur", "\(d1.temperature) °C")
            MetricRow("Verbraucht", String(format: "%.2f Ah", d1.consumedAh))
            MetricRow("Restlaufzeit", "\(d2.timeToGo) min")
        }
    }
}

struct SolarBoosterCard: View {
    @EnvironmentObject var model: Model

    var body: some View {
        SectionCard("Solar & Booster", systemImage: "sun.max.fill") {
            MetricRow("Solar", String(format: "%.2f A", model.adcSolar.solarA))
            MetricRow("Solar Leistung", String(format: "%.1f W", model.adcSolar.solarW))
            MetricRow("Solar gesamt", String(format: "%.2f kWh", model.adcSolar.solarTotalWh / 1000))
            MetricRow("Booster", String(format: "%.2f A", model.adcBooster.boosterA))
            MetricRow("Booster Leistung", String(format: "%.1f W", model.adcBooster.boosterW))
            MetricRow("Booster gesamt", String(format: "%.2f kWh", model.adcBooster.boosterTotalWh / 1000))
        }
    }
}

struct WaterCard: View {
    @EnvironmentObject var model: Model

    var body: some View {
        let pressure = ((Double(model.adcData.waterPressureBar) * 0.45) + 0.5 - 1 - 0.42) * 25 * 0.0689476
        SectionCard("Wasser", systemImage: "drop.fill") {
            MetricRow("Wasserdruck", String(format: "%.2f bar", pressure))
            MetricRow("Abwassertemperatur", String(format: "%.2f °C", model.sewageTemperature))
            MetricRow("Warmwasser", String(format: "%.2f l/min", model.waterFlowData.warmFlow))
            MetricRow("Warmwasser gesamt", String(format: "%.2f l", model.waterFlowData.warmTotal))
            MetricRow("Wasserfilter", String(format: "%.2f l/min", model.waterFlowData.filterFlow))
            MetricRow("Wasserfilter gesamt", String(format: "%.2f l", model.waterFlowData.filterTotal))
        }
    }
}

struct SensorCard: View {
    @EnvironmentObject var model: Model

    var body: some View {
        let rawVoltage = (Double(model.adcData.waterPressureBar) * 0.45) + 0.5
        SectionCard("Drucksensor", systemImage: "gauge.with.dots.needle.bottom.50percent") {
            MetricRow("Rohspannung", String(format: "%.2f V", rawVoltage))
            MetricRow("Kalibrierfaktor", String(format: "%.3f", model.adcSettings.waterPressure.calibrationFactor))
            MetricRow("Offset", String(format: "%.3f", model.adcSettings.waterPressure.offset))
        }
    }
}

struct BatteryDetailsCard: View {
    @EnvironmentObject var model: Model

    var body: some View {
        let d2 = model.veDirectData2
        let d3 = model.veDirectData3
        let d4 = model.veDirectData4
        let d5 = model.veDirectData5
        SectionCard("Batterie-Details", systemImage: "chart.bar.fill") {
            MetricRow("Firmware", "\(d2.firmwareVersion)")
            MetricRow("Alarm", "\(d2.alarm)")
            MetricRow("Alarmgrund", "\(d2.alarmReason)")
            MetricRow("Zyklen", "\(d3.numberOfCycles)")
            MetricRow("Vollentladungen", "\(d3.numberOfFullDischarge)")
            MetricRow("Tiefste Entladung", String(format: "%.2f Ah", d3.depthOfDeepesDischarge))
            MetricRow("Letzte Entladung", String(format: "%.2f Ah", d3.depthOfLastDischarge))
            MetricRow("Mittlere Entladung", String(format: "%.2f Ah", d3.depthOfAvarageDischarge))
            MetricRow("Kumulativ entnommen", String(format: "%.2f Ah", d4.cumulativeAmpHoursDrawn))
            MetricRow("Min. Spannung", String(format: "%.2f V", d4.minVoltage))
            MetricRow("Max. Spannung", String(format: "%.2f V", d4.maxVoltage))
            MetricRow("Seit Vollladung", "\(d4.secondsSinceLastFullCharge) s")
            MetricRow("Auto-Synchronisationen", "\(d4.numberOfAutomaticSynchronisations)")
            MetricRow("Unterspannungsalarme", "\(d5.numOfLowVoltageAlarms)")
            MetricRow("Überspannungsalarme", "\(d5.numOfHighVoltageAlarms)")
            MetricRow("Entladene Energie", String(format: "%.2f kWh", d5.amountOfDischargedEnergy))
        }
    }
}

// MARK: - Reusable building blocks

/// A titled, rounded content card matching the app's card styling.
struct SectionCard<Content: View>: View {
    let title: String
    let systemImage: String
    @ViewBuilder let content: Content

    init(_ title: String, systemImage: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.systemImage = systemImage
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: systemImage)
                .font(.headline)

            VStack(spacing: 8) {
                content
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
    }
}

/// A single label/value row: label on the left, value right-aligned and monospaced.
struct MetricRow: View {
    let label: String
    let value: String

    init(_ label: String, _ value: String) {
        self.label = label
        self.value = value
    }

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer(minLength: 12)
            Text(value)
                .fontWeight(.medium)
                .monospacedDigit()
        }
        .font(.subheadline)
    }
}

struct DataView_Previews: PreviewProvider {
    static var previews: some View {
        DataView()
            .environmentObject(Model(bluetoothService: BluetoothService()))
    }
}
