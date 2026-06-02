//
//  AdcData.swift
//  Pumba
//
//  Created by Marcel Breska on 30.06.23.
//

import Foundation

struct AdcData: Codable {
  var batteryV: Float = 0
  var solarV: Float = 0
  var sewageV: Float = 0
  var waterPressureBar: Float = 0
}

struct AdcSolar: Codable {
    var solarA: Float = 0
    var solarAh: Float = 0
    var solarW: Float = 0
    var solarWh: Float = 0
    var solarTotalWh: Float = 0
}

struct AdcBooster: Codable {
    var boosterA: Float = 0
    var boosterAh: Float = 0
    var boosterW: Float = 0
    var boosterWh: Float = 0
    var boosterTotalWh: Float = 0
}
