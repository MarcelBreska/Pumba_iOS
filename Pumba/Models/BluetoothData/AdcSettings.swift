//
//  AdcSettings.swift
//  Pumba
//
//  Created by Marcel Breska on 30.06.23.
//

import Foundation

struct ADCSettings: Codable {
    struct AdcCalibration: Codable {
        var offset: Float = 0
        var calibrationFactor: Float = 1
    }
    
    var battery = AdcCalibration()
    var solar = AdcCalibration()
    var waterPressure = AdcCalibration()
    var solarShunt = AdcCalibration()
    var boosterShunt = AdcCalibration()
}
