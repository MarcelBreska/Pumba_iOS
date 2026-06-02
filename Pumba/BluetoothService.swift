//
//  BluetoothService.swift
//  Pumba
//
//  Created by Marcel Breska on 28.06.23.
//

import Foundation
import CoreBluetooth
import Combine

let SEWAGE_TEMPERATURE_ID = "119bf4d9-e770-484a-9463-13cfe9ef3ad8"
let WATERPUMP_ID = "0dd6e1fb-02d9-4234-927c-e899dad9ca6c"
let INVERTER_ID = "c80700a3-501a-4bd2-86ab-f5b4369e484d"
let TANK_HEATER_ID = "9a73a3d2-da71-49dc-8e07-07197fa882f1"
let SEWAGE_VALVE_ID = "5ed84000-5fd9-4de4-82f9-2f8df7e76ed2"

let CLOSET_LOCK_ID = "8ae37aea-e595-47ee-9c4c-414186599d94"
let KITCHEN_SERVO_POS_ID = "b2680d56-62fc-4456-82a2-1ad545aa3fe6"
let WALL_CUPBOARD_SERVO_POS_ID = "9d95be3b-3ecf-4592-ae98-581eb09d26d8"

let WATER_FLOW_ID = "44470e73-8b8b-43a5-94b2-d219d7572c05"

let ADC_ID = "4e083890-2230-4cba-9d77-6cc1edc8ab66"
let ADC_SOLAR_ID = "a39e1978-730d-4b3c-8a02-d0e44bacc6a3"
let ADC_BOOSTER_ID = "90216072-e70c-4ac3-844c-e8f36aaa8dcf"
let ACCELERATION_ID = "2c5e085f-681b-45ca-bf1e-b71e76c9f655"

let VE_DIRECT1_ID = "c89668a4-09a4-4fd7-8d71-2b08f0538b94"
let VE_DIRECT2_ID = "8f6ebaf9-6665-426d-a4a1-f6a3ac44bc87"
let VE_DIRECT3_ID = "015a1eb6-5f26-4546-9304-76242f3daea0"
let VE_DIRECT4_ID = "2fc626b1-ee55-4874-b2d1-31308b818d64"
let VE_DIRECT5_ID = "7a52e615-50f2-4686-b2ed-0b376b22e968"

let ADC_SETTINGS_ID = "b865a004-557c-417a-a92c-78d0788b185a"
let SERVO_SETTINGS_ID = "c65528e2-98d7-49ef-92aa-f6f2d432abd0"
let SERVO_SETTINGS_CUPBOARD_ID = "867b9acd-39ed-4243-8814-57f9539cd3cc"
let FLOW_SETTINGS_ID = "407690f1-008a-4f58-9808-22e4bb98d1e4"

enum BluetoothData {
    case sewageTemperature(Float)
    case waterFlowData(WaterFlowData)
    case adcData(AdcData)
    case adcSolar(AdcSolar)
    case adcBooster(AdcBooster)
    case isInverterOn(Bool)
    case isWaterpumpOn(Bool)
    case isTankHeaterOn(Bool)
    case isSewageValveOpen(Bool)
    case isClosetLocked(Bool)
    case kitechenServoPos(Float)
    case wallCupboardServoPos(Float)
    case imuData(ImuData)
    case veDirectData1(VEDirectData1)
    case veDirectData2(VEDirectData2)
    case veDirectData3(VEDirectData3)
    case veDirectData4(VEDirectData4)
    case veDirectData5(VEDirectData5)
    case adcSettings(ADCSettings)
    case servoSettings(ServoSettings)
    case servoSettingsCupboard(ServoSettingsCupboard)
    case flowSettings(FlowSettings)
}

struct Peripheral: Identifiable, Hashable {
    let id: String
    let name: String
}

class BluetoothService: NSObject {
    private var centralManager: CBCentralManager?
    
    private var peripherals: [CBPeripheral] = []
    private var peripheral: CBPeripheral? = nil {
        didSet {
//            print("current peripheral \(peripheral?.name)")
            isConnectedPublisher.send(peripheral != nil)
        }
    }
    
    private var characteristics: [CBCharacteristic]? = nil
    
    let bluetoothDataPublisher = PassthroughSubject<BluetoothData, Never>()
    let peripheralPublisher = PassthroughSubject<[Peripheral], Never>()
    let isConnectedPublisher = PassthroughSubject<Bool, Never>()
    
    override init() {
        super.init()
        // Skip CoreBluetooth in SwiftUI previews so they don't start a live scan.
        guard ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != "1" else { return }
        self.centralManager = CBCentralManager(delegate: self, queue: .main)
    }
    
    private func connectPeripheral(peripheral: CBPeripheral) {
        centralManager?.connect(peripheral, options: nil)
    }
    
    func connectPeripheral(peripheral: Peripheral) {
        guard let peripheral = peripherals.first(where: { $0.identifier.uuidString == peripheral.id } ) else { return }
        centralManager?.connect(peripheral, options: nil)
    }
    
    func scanForDevices() {
        peripherals = []
        centralManager?.scanForPeripherals(withServices: nil)
    }
    
    private func updateRelay(isActive: Bool, id: String) {
        guard let characteristic = characteristics?.first(where: { charateristic in
            return charateristic.uuid.uuidString.lowercased() == id
        }) else { return }
        let value = UInt8(isActive ? 1 : 0)
        peripheral?.writeValue(Data([value]), for: characteristic, type: .withResponse)
    }
    
    func updateInverter(isOn: Bool) {
        updateRelay(isActive: isOn, id: INVERTER_ID)
    }
    
    func updateWaterpump(isOn: Bool) {
        updateRelay(isActive: isOn, id: WATERPUMP_ID)
    }
    
    func updateTankHeater(isOn: Bool) {
        updateRelay(isActive: isOn, id: TANK_HEATER_ID)
    }
    
    func updateSewageValve(isOn: Bool) {
        updateRelay(isActive: isOn, id: SEWAGE_VALVE_ID)
    }
    
    func updateKitchenLock(isLocked: Bool) {
        updateRelay(isActive: isLocked, id: CLOSET_LOCK_ID)
    }
    
    func updateServoSettings(servoSettings: ServoSettings) {
        guard let characteristic = characteristics?.first(where: { charateristic in
            return charateristic.uuid.uuidString.lowercased() == SERVO_SETTINGS_ID
        }) else { return }
        
        let data = encodeStruct(servoSettings)
        peripheral?.writeValue(data, for: characteristic, type: .withResponse)
    }
    
    func updateServoSettingsCupboard(servoSettings: ServoSettingsCupboard) {
        guard let characteristic = characteristics?.first(where: { charateristic in
            return charateristic.uuid.uuidString.lowercased() == SERVO_SETTINGS_CUPBOARD_ID
        }) else { return }

        let data = encodeStruct(servoSettings)
        peripheral?.writeValue(data, for: characteristic, type: .withResponse)
    }
    
//    func updateKitchenServoPos() {
//        print("updateKitcehnServoPos")
//        
//        guard let characteristic = characteristics?.first(where: { charateristic in
//            return charateristic.uuid.uuidString.lowercased() == KITCHEN_SERVO_POS_ID
//        }) else { return }
//        let value = UInt8(kitchenServoPos)
//        print("setValue \(value)")
//        peripheral?.writeValue(Data([value]), for: characteristic, type: .withResponse)
//    }
//    
//    func updateWallCupboardServoPos() {
//        print("updateWallCupboadServoPos")
//        
//        guard let characteristic = characteristics?.first(where: { charateristic in
//            return charateristic.uuid.uuidString.lowercased() == WALL_CUPBOARD_SERVO_POS_ID
//        }) else { return }
//        let value = UInt8(wallCupboardServoPos)
//        print("setValue \(value)")
//        peripheral?.writeValue(Data([value]), for: characteristic, type: .withResponse)
//    }
//    
//    func updateADCSettingsData() {
//        guard let characteristic = characteristics?.first(where: { charateristic in
//            return charateristic.uuid.uuidString.lowercased() == ADC_SETTINGS_ID
//        }) else { return }
//        
//        let data = encodeStruct(adcSettings)
//        print("updateADCSettingsData")
//        print(data)
//        
//        peripheral?.writeValue(data, for: characteristic, type: .withResponse)
//    }
//    
//    func updateServoSettingsData() {
//        guard let characteristic = characteristics?.first(where: { charateristic in
//            return charateristic.uuid.uuidString.lowercased() == SERVO_SETTINGS_ID
//        }) else { return }
//        
//        let data = encodeStruct(servoSettings)
//        print("updateServoSettingsData")
//        print(data)
//        
//        peripheral?.writeValue(data, for: characteristic, type: .withResponse)
//    }
//    
//    func updateFlowSettingsData() {
//        guard let characteristic = characteristics?.first(where: { charateristic in
//            return charateristic.uuid.uuidString.lowercased() == FLOW_SETTINGS_ID
//        }) else { return }
//        
//        let data = encodeStruct(flowSettings)
//        print("updateFlowSettingsData")
//        print(data)
//        
//        peripheral?.writeValue(data, for: characteristic, type: .withResponse)
//    }
    
    func encodeStruct<T>(_ value: T) -> Data {
        var valueCopy = value
        return Data(bytes: &valueCopy, count: MemoryLayout<T>.size)
    }
}

extension BluetoothService: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            self.centralManager?.scanForPeripherals(withServices: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if !peripherals.contains(peripheral) {
            self.peripherals.append(peripheral)
        }
        
        
//        print("peripheral \(peripheral.identifier.description), \(peripheral.name), \(peripheral.identifier)")
        
        if peripheral.name == "Pumba_Zentrale" {
            connectPeripheral(peripheral: peripheral)
        }

        peripheralPublisher.send(peripherals.map { Peripheral(id: $0.identifier.uuidString, name: $0.name ?? "unnamed device")})
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        central.stopScan()
        self.peripheral = peripheral
        self.peripheral?.delegate = self
        peripheral.discoverServices(nil)
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        self.peripheral = nil
        // Resume scanning so the device is rediscovered and auto-reconnected.
        central.scanForPeripherals(withServices: nil)
    }
}

extension BluetoothService: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        characteristics = service.characteristics
        
        for characteristic in characteristics ?? [] {
            peripheral.readValue(for: characteristic)
            peripheral.setNotifyValue(true, for: characteristic)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services, error == nil else {
            return
        }
        
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let data = characteristic.value else { return }
        switch characteristic.uuid.uuidString.lowercased() {
        case SEWAGE_TEMPERATURE_ID:
            let temp = parseFloat(data: data)
            let data = BluetoothData.sewageTemperature(temp)
            publishBluetoothData(data: data)
        case WATER_FLOW_ID:
            guard let waterFlowData: WaterFlowData = parseStruct(data: data) else { return }
            let data = BluetoothData.waterFlowData(waterFlowData)
            publishBluetoothData(data: data)
        case ADC_ID:
            guard let adcData: AdcData = parseStruct(data: data) else { return }
            let data = BluetoothData.adcData(adcData)
            publishBluetoothData(data: data)
        case ADC_SOLAR_ID:
            guard let adcData: AdcSolar = parseStruct(data: data) else { return }
            let data = BluetoothData.adcSolar(adcData)
            publishBluetoothData(data: data)
        case ADC_BOOSTER_ID:
            guard let adcData: AdcBooster = parseStruct(data: data) else { return }
            let data = BluetoothData.adcBooster(adcData)
            publishBluetoothData(data: data)
        case INVERTER_ID:
            let isOn = parseBool(data: data)
            let data = BluetoothData.isInverterOn(isOn)
            publishBluetoothData(data: data)
        case WATERPUMP_ID:
            let isOn = parseBool(data: data)
            let data = BluetoothData.isWaterpumpOn(isOn)
            publishBluetoothData(data: data)
        case TANK_HEATER_ID:
            let isOn = parseBool(data: data)
            let data = BluetoothData.isTankHeaterOn(isOn)
            publishBluetoothData(data: data)
        case SEWAGE_VALVE_ID:
            let isOpen = parseBool(data: data)
            let data = BluetoothData.isSewageValveOpen(isOpen)
            publishBluetoothData(data: data)
        case CLOSET_LOCK_ID:
            let isLocked = parseBool(data: data)
            let data = BluetoothData.isClosetLocked(isLocked)
            publishBluetoothData(data: data)
        case KITCHEN_SERVO_POS_ID:
            let servoPos = Float(parseInt(data: data))
            let data = BluetoothData.kitechenServoPos(servoPos)
            publishBluetoothData(data: data)
        case WALL_CUPBOARD_SERVO_POS_ID:
            let servoPos = Float(parseInt(data: data))
            let data = BluetoothData.wallCupboardServoPos(servoPos)
            publishBluetoothData(data: data)
        case ACCELERATION_ID:
            guard let accData: ImuData = parseStruct(data: data) else { return }
            let data = BluetoothData.imuData(accData)
            publishBluetoothData(data: data)
            
        case VE_DIRECT1_ID:
            guard let veDirectData: VEDirectData1 = parseStruct(data: data) else { return }
            let data = BluetoothData.veDirectData1(veDirectData)
            publishBluetoothData(data: data)
        case VE_DIRECT2_ID:
            guard let veDirectData: VEDirectData2 = parseStruct(data: data) else { return }
            let data = BluetoothData.veDirectData2(veDirectData)
            publishBluetoothData(data: data)
        case VE_DIRECT3_ID:
            guard let veDirectData: VEDirectData3 = parseStruct(data: data) else { return }
            let data = BluetoothData.veDirectData3(veDirectData)
            publishBluetoothData(data: data)
        case VE_DIRECT4_ID:
            guard let veDirectData: VEDirectData4 = parseStruct(data: data) else { return }
            let data = BluetoothData.veDirectData4(veDirectData)
            publishBluetoothData(data: data)
        case VE_DIRECT5_ID:
            guard let veDirectData: VEDirectData5 = parseStruct(data: data) else { return }
            let data = BluetoothData.veDirectData5(veDirectData)
            publishBluetoothData(data: data)
        case ADC_SETTINGS_ID:
            guard let adcSettings: ADCSettings = parseStruct(data: data) else { return }
            let data = BluetoothData.adcSettings(adcSettings)
            publishBluetoothData(data: data)
        case SERVO_SETTINGS_ID:
            guard let servoSettings: ServoSettings = parseStruct(data: data) else { return }
            let data = BluetoothData.servoSettings(servoSettings)
            publishBluetoothData(data: data)
        case SERVO_SETTINGS_CUPBOARD_ID:
            guard let servoSettings: ServoSettingsCupboard = parseStruct(data: data) else { return }
            let data = BluetoothData.servoSettingsCupboard(servoSettings)
            publishBluetoothData(data: data)
        case FLOW_SETTINGS_ID:
            guard let flowSettings: FlowSettings = parseStruct(data: data) else { return }
            let data = BluetoothData.flowSettings(flowSettings)
            publishBluetoothData(data: data)
        default:
            break
        }
    }
    
    func publishBluetoothData(data: BluetoothData) {
        bluetoothDataPublisher.send(data)
    }
}

extension BluetoothService {
    func parseStruct<T>(data: Data) -> T? {
        guard data.count >= MemoryLayout<T>.size else {
            return nil
        }

        return data.withUnsafeBytes { $0.loadUnaligned(as: T.self) }
    }
    
    func parseFloat(data: Data) -> Float {
        let bytes:Array<UInt8> = data.map { $0 }

        var value:Float = 0.0

        memcpy(&value, bytes, 4)
        return value
    }
    
    func parseInt(data: Data) -> Int {
        let bytes: [UInt8] = data.map { $0 }

        var value: Int32 = 0

        memcpy(&value, bytes, 4)
        return Int(value)
    }
    
    func parseBool(data: Data) -> Bool {
        return data.first == 1
    }
}
