//
//  ImuData.swift
//  Pumba
//
//  Created by Marcel Breska on 30.06.23.
//

import Foundation

struct ImuData: Codable {
    var ax: Float = 0
    var ay: Float = 0
    var az: Float = 0
    var pitch: Float = 0.0
    var roll: Float = 0.0
}
