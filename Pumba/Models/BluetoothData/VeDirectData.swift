//
//  VeDirectData.swift
//  Pumba
//
//  Created by Marcel Breska on 30.06.23.
//

import Foundation

struct VEDirectData1: Codable {
    var voltage: Float = 0
    var temperature: Int32 = 0
    var current: Float = 0
    var power: Int32 = 0
    var consumedAh: Float = 0
}

struct VEDirectData2: Codable {
    var soc: Float = 0
    var timeToGo: Int32 = 0
    var alarm: Int32 = 0
    var alarmReason: Int32 = 0
    var firmwareVersion: Int32 = 0
}

struct VEDirectData3: Codable {
    var depthOfDeepesDischarge: Float = 0
    var depthOfLastDischarge: Float = 0
    var depthOfAvarageDischarge: Float = 0
    var numberOfCycles: Int32 = 0
    var numberOfFullDischarge: Int32 = 0
}

struct VEDirectData4: Codable {
    var cumulativeAmpHoursDrawn: Float = 0
    var minVoltage: Float = 0
    var maxVoltage: Float = 0
    var secondsSinceLastFullCharge: Int32 = 0
    var numberOfAutomaticSynchronisations: Int32 = 0
}

struct VEDirectData5: Codable {
    var numOfLowVoltageAlarms: Int32 = 0
    var numOfHighVoltageAlarms: Int32 = 0
    var amountOfDischargedEnergy: Float = 0
}
