//
//  Model.swift
//  Pumba
//
//  Created by Marcel Breska on 29.06.23.
//

import Foundation
import Combine

@MainActor
class Model: ObservableObject {
    private let bluetoothService: BluetoothService
    
    private var cancellables: Set<AnyCancellable> = []
    
    @Published var peripherals: [Peripheral] = []
    @Published var peripheral: Peripheral? = nil
    @Published var isInverterOn = false
    @Published var isWaterpumpOn = false
    @Published var isLocked = false
    @Published var isSewageOpen = false
    @Published var isTankHeaterOn = false
    
    @Published var sewageTemperature: CGFloat = 0
    
    @Published var soc: CGFloat = 0
    @Published var solarW: CGFloat = 0
    @Published var boosterW: CGFloat = 0
    @Published var batteryW: CGFloat = 0
    
    @Published var openPosMaxKitchen: Double = 0
    @Published var openPosHoldKitchen: Double = 0
    @Published var closedPosMaxKitchen: Double = 0
    @Published var closedPosHoldKitchen: Double = 0
    
    @Published var openPosMaxCupboard: Double = 0
    @Published var openPosHoldCupboard: Double = 0
    @Published var closedPosMaxCupboard: Double = 0
    @Published var closedPosHoldCupboard: Double = 0
    
    @Published var veDirectData1 = VEDirectData1()
    @Published var veDirectData2 = VEDirectData2()
    @Published var veDirectData3 = VEDirectData3()
    @Published var veDirectData4 = VEDirectData4()
    @Published var veDirectData5 = VEDirectData5()
    @Published var adcData = AdcData()
    @Published var adcSolar = AdcSolar()
    @Published var adcBooster = AdcBooster()
    @Published var imuData = ImuData()
    @Published var waterFlowData = WaterFlowData()
    @Published var adcSettings = ADCSettings()
    
    @Published var servoSettings = ServoSettings()
    @Published var servoSettingsCupboard = ServoSettingsCupboard()
    
    @Published var isConnected = false
    
    var isServoSet = false
    
    init(bluetoothService: BluetoothService) {
        self.bluetoothService = bluetoothService
        
        setupPeripheralListener()
        setupBluetoothDataListener()
        setupConnectionListener()
    }
    
    private func setupPeripheralListener() {
        bluetoothService.peripheralPublisher
            .sink { [weak self] peripherals in
                self?.peripherals = peripherals
            }
            .store(in: &cancellables)
    }

    private func setupConnectionListener() {
        bluetoothService.isConnectedPublisher
            .sink { [weak self] isConnected in
                self?.isConnected = isConnected
            }
            .store(in: &cancellables)
    }

    private func setupBluetoothDataListener() {
        bluetoothService.bluetoothDataPublisher
            .sink { [weak self] bluetoothData in
                guard let self else { return }
                switch bluetoothData {
                case .isInverterOn(let isOn):
                    self.isInverterOn = isOn
                case .isWaterpumpOn(let isOn):
                    self.isWaterpumpOn = isOn
                case .isClosetLocked(let isLocked):
                    self.isLocked = isLocked
                case .isSewageValveOpen(let isOpen):
                    self.isSewageOpen = isOpen
                case .isTankHeaterOn(let isOn):
                    self.isTankHeaterOn = isOn
                case .sewageTemperature(let temperature):
                    self.sewageTemperature = CGFloat(temperature)
                case .adcData(let data):
                    self.adcData = data
                case .adcSolar(let data):
                    self.solarW = CGFloat(data.solarW)
                    self.adcSolar = data
                case .adcBooster(let data):
                    self.boosterW = CGFloat(data.boosterW)
                    self.adcBooster = data
                    
                case .veDirectData1(let data):
                    self.batteryW = CGFloat(data.power)
                    self.veDirectData1 = data
                case .veDirectData2(let data):
                    self.soc = CGFloat(data.soc)
                    self.veDirectData2 = data
                case .veDirectData3(let data):
                    self.veDirectData3 = data
                case .veDirectData4(let data):
                    self.veDirectData4 = data
                case .veDirectData5(let data):
                    self.veDirectData5 = data
                    
                case .waterFlowData(let data):
                    self.waterFlowData = data
                case .adcSettings(let settings):
                    self.adcSettings = settings
                case .servoSettings(let settings):
                    self.servoSettings = settings
                    guard !self.isServoSet else { return }
                    self.openPosMaxKitchen = Double(settings.openPosMaxKitchen)
                    self.openPosHoldKitchen = Double(settings.openPosHoldKitchen)
                    self.closedPosMaxKitchen = Double(settings.closedPosMaxKitchen)
                    self.closedPosHoldKitchen = Double(settings.closedPosHoldKitchen)
                    self.isServoSet = true
                case .servoSettingsCupboard(let settings):
                    self.servoSettingsCupboard = settings
                    guard !self.isServoSet else { return }
                    self.openPosMaxCupboard = Double(settings.openPosMaxWallCupboard)
                    self.openPosHoldCupboard = Double(settings.openPosHoldWallCupboard)
                    self.closedPosMaxCupboard = Double(settings.closedPosMaxWallCupboard)
                    self.closedPosHoldCupboard = Double(settings.closedPosHoldWallCupboard)
                    self.isServoSet = true
                case .imuData(let data):
                    self.imuData = data
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }
    
    func scanForDevices() {
        bluetoothService.scanForDevices()
    }
    
    func connectPeripheral(peripheral: Peripheral) {
        bluetoothService.connectPeripheral(peripheral: peripheral)
    }
    
    func updateInverter(isOn: Bool) {
        bluetoothService.updateInverter(isOn: isOn)
    }
    
    func updateWaterpump(isOn: Bool) {
        bluetoothService.updateWaterpump(isOn: isOn)
    }
    
    func updateTankHeater(isOn: Bool) {
        bluetoothService.updateTankHeater(isOn: isOn)
    }
    
    func updateSewageValve(isOn: Bool) {
        bluetoothService.updateSewageValve(isOn: isOn)
    }
    
    func updateKitchenLock(isLocked: Bool) {
        bluetoothService.updateKitchenLock(isLocked: isLocked)
    }
    
    func updateServoSettings() {
        servoSettings.openPosMaxKitchen = Int32(openPosMaxKitchen)
        servoSettings.openPosHoldKitchen = Int32(openPosHoldKitchen)
        servoSettings.closedPosMaxKitchen = Int32(closedPosMaxKitchen)
        servoSettings.closedPosHoldKitchen = Int32(closedPosHoldKitchen)
        bluetoothService.updateServoSettings(servoSettings: servoSettings)
    }
    
    func updateServoSettingsCupboard() {
        servoSettingsCupboard.openPosMaxWallCupboard = Int32(openPosMaxCupboard)
        servoSettingsCupboard.openPosHoldWallCupboard = Int32(openPosHoldCupboard)
        servoSettingsCupboard.closedPosMaxWallCupboard = Int32(closedPosMaxCupboard)
        servoSettingsCupboard.closedPosHoldWallCupboard = Int32(closedPosHoldCupboard)
        bluetoothService.updateServoSettingsCupboard(servoSettings: servoSettingsCupboard)
    }
}
