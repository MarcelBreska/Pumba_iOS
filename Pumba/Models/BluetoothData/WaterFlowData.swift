//
//  WaterFlowData.swift
//  Pumba
//
//  Created by Marcel Breska on 30.06.23.
//

import Foundation

struct WaterFlowData: Codable {
    var warmFlow: Float = 0.0
    var warmTotal: Float = 0.0
    var warmInterval: Float = 0.0
    var filterFlow: Float = 0.0
    var filterTotal: Float = 0.0
    var filterInterval: Float = 0.0
}
