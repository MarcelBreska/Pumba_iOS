//
//  ContentView.swift
//  Pumba
//
//  Created by Marcel Breska on 24.04.23.
//

import SwiftUI
import CoreBluetooth

let SEWAGE_TEMPERATURE_ID = "119bf4d9-e770-484a-9463-13cfe9ef3ad8"
let WATERPUMP_ID = "0dd6e1fb-02d9-4234-927c-e899dad9ca6c"
let INVERTER_ID = "c80700a3-501a-4bd2-86ab-f5b4369e484d"
let TANK_HEATER_ID = "9a73a3d2-da71-49dc-8e07-07197fa882f1"
let SEWAGE_VALVE_ID = "5ed84000-5fd9-4de4-82f9-2f8df7e76ed2"
let KITCHEN_SERVO_ID = "8ae37aea-e595-47ee-9c4c-414186599d94"
let IS_LOCKED_ID = "992df6a6-51d7-4649-b832-838b5f7bc363"

let WATER_FLOW_ID = "44470e73-8b8b-43a5-94b2-d219d7572c05"

let ADC_ID = "4e083890-2230-4cba-9d77-6cc1edc8ab66"
let ACCELERATION_ID = "2c5e085f-681b-45ca-bf1e-b71e76c9f655"
let VE_DIRECT_ID = "c89668a4-09a4-4fd7-8d71-2b08f0538b94"
let ADC_SETTINGS_ID = "b865a004-557c-417a-a92c-78d0788b185a"
let SERVO_SETTINGS_ID = "c65528e2-98d7-49ef-92aa-f6f2d432abd0"
let FLOW_SETTINGS_ID = "407690f1-008a-4f58-9808-22e4bb98d1e4"

struct AccelerationData: Codable {
    var ax: Float = 0.0
    var ay: Float = 0.0
    var az: Float = 0.0
}

struct WaterFlowData: Codable {
    var warmFlow: Float = 0.0
    var warmTotal: Float = 0.0
    var filterFlow: Float = 0.0
    var filterTotal: Float = 0.0
};

struct AdcData: Codable {
  var batteryV: Float = 0.0
  var solarV: Float = 0.0
  var sewageV: Float = 0.0
  var waterPressureV: Float = 0.0
  var boosterA: Float = 0.0
  var boosterAh: Float = 0.0
  var boosterW: Float = 0.0
  var boosterWh: Float = 0.0
  var boosterTotalWh: Float = 0.0
  var solarA: Float = 0.0
  var solarAh: Float = 0.0
  var solarW: Float = 0.0
  var solarWh: Float = 0.0
  var solarTotalWh: Float = 0.0
};

struct VEDirectData: Codable {
    var soc: Float = 0.0
    var power: Float = 0.0
};

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

struct ServoSettings {
    var openPosMaxKitchen: Int32 = 0
    var openPosHoldKitchen: Int32 = 0
    var closedPosMaxKitchen: Int32 = 0
    var closedPosHoldKitchen: Int32 = 0
    var maxTimeKitchen: Int32 = 0

    var openPosWallCupboard: Int32 = 0
    var closedPosWallCupboard: Int32 = 0
};

struct FlowSettings {
  var warmWaterFlowCalibrationFactor: Float = 1
    var filterWaterFlowCalibrationFactor: Float = 1
};

class BluetoothViewModel: NSObject, ObservableObject {
    private var centralManager: CBCentralManager?
    @Published var peripherals: [CBPeripheral] = []
    @Published var peripheralNames: [String] = []
    @Published var peripheral: CBPeripheral? = nil
    @Published var characteristics: [CBCharacteristic]? = nil
    @Published var data: [String] = []
    @Published var sewageTemperature: Float = 0
    
    @Published var waterFlowData = WaterFlowData()
    @Published var accData = AccelerationData()
    @Published var veDirectData = VEDirectData()
    @Published var adcData = AdcData()
    @Published var adcSettings = ADCSettings()
    @Published var servoSettings = ServoSettings()
    @Published var flowSettings = FlowSettings()
    
    @Published var isInverterOn: Bool = false 
    @Published var waterpumpIsOn: Bool = false
    @Published var tankHeaterIsOn: Bool = false
    @Published var isSewageValveOpen: Bool = false
    @Published var isLocked: Bool = false
    
    @Published var isDataReady: Bool = false
    
    override init() {
        super.init()
        self.centralManager = CBCentralManager(delegate: self, queue: .main)
    }
    
    func connectPeripheral(_ selectPeripheral: CBPeripheral?) {
        guard let connectPeripheral = selectPeripheral else { return }
        centralManager?.connect(connectPeripheral, options: nil)
    }
    
    func scanForDevices() {
        peripherals = []
        peripheralNames = []
        centralManager?.scanForPeripherals(withServices: nil)
    }
    
    func updateInverter(isOn: Bool) {
        print("updateInverter")
        
        guard let characteristic = characteristics?.first(where: { charateristic in
            return charateristic.uuid.uuidString.lowercased() == INVERTER_ID
        }) else { return }
        let value = UInt8(isOn ? 1 : 0)
        print("setValue \(value)")
        peripheral?.writeValue(Data([value]), for: characteristic, type: .withResponse)
    }
    
    func updateWaterpump(isOn: Bool) {
        print("updateWaterpump")
        
        guard let characteristic = characteristics?.first(where: { charateristic in
            return charateristic.uuid.uuidString.lowercased() == WATERPUMP_ID
        }) else { return }
        let value = UInt8(isOn ? 1 : 0)
        print("setValue \(value)")
        peripheral?.writeValue(Data([value]), for: characteristic, type: .withResponse)
            
    }
    
    func updateTankHeater(isOn: Bool) {
        print("updateTankHeater")
        
        guard let characteristic = characteristics?.first(where: { charateristic in
            return charateristic.uuid.uuidString.lowercased() == TANK_HEATER_ID
        }) else { return }
        let value = UInt8(isOn ? 1 : 0)
        print("setValue \(value)")
        peripheral?.writeValue(Data([value]), for: characteristic, type: .withResponse)
    }
    
    func updateSewageValve(isOn: Bool) {
        print("updateSewageValve")
        
        guard let characteristic = characteristics?.first(where: { charateristic in
            return charateristic.uuid.uuidString.lowercased() == SEWAGE_VALVE_ID
        }) else { return }
        let value = UInt8(isOn ? 1 : 0)
        print("setValue \(value)")
        peripheral?.writeValue(Data([value]), for: characteristic, type: .withResponse)
            
    }
    
    func updateKitchenLock(isLocked: Bool) {
        print("updateKitchenLock")
        
        guard let characteristic = characteristics?.first(where: { charateristic in
            return charateristic.uuid.uuidString.lowercased() == KITCHEN_SERVO_ID
        }) else { return }
        let value = UInt8(isLocked ? 83 : 35)
        print("setValue \(value)")
        peripheral?.writeValue(Data([value]), for: characteristic, type: .withResponse)
        
        if (!isLocked) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
                let value = UInt8(66)
                print("setValue \(value)")
                self?.peripheral?.writeValue(Data([value]), for: characteristic, type: .withResponse)
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
                let value = UInt8(78)
                print("setValue \(value)")
                self?.peripheral?.writeValue(Data([value]), for: characteristic, type: .withResponse)
            }
        }
            
    }
    
    func updateServoPos(pos: Double) {
        print("updateServoPos")
        
        guard let characteristic = characteristics?.first(where: { charateristic in
            return charateristic.uuid.uuidString.lowercased() == KITCHEN_SERVO_ID
        }) else { return }
        let value = UInt8(pos)
        print("setValue \(value)")
        peripheral?.writeValue(Data([value]), for: characteristic, type: .withResponse)
    }
    
    func updateADCSettingsData() {
        guard let characteristic = characteristics?.first(where: { charateristic in
            return charateristic.uuid.uuidString.lowercased() == ADC_SETTINGS_ID
        }) else { return }
        
        guard let data = convertToData(settings: adcSettings) else {
            print("conversion not possible")
            return
        }
        print("updateADCSettingsData")
        print(data)
        
//        peripheral?.writeValue(data, for: characteristic, type: .withResponse)
    }
    
    func convertToData(settings: ADCSettings) -> Data? {
        let encoder = JSONEncoder()
        do {
            let jsonData = try encoder.encode(settings)
            return jsonData
        } catch {
            print("Failed to convert struct to data: \(error)")
            return nil
        }
    }
}

extension BluetoothViewModel: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            self.centralManager?.scanForPeripherals(withServices: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if !peripherals.contains(peripheral) {
            self.peripherals.append(peripheral)
            self.peripheralNames.append(peripheral.name ?? "unnamed device")
        }
        
        if peripheral.identifier.uuidString.lowercased() == "FDBEBDDD-222B-4F5C-4B3A-EDC0BC5C3DBB".lowercased() {
            connectPeripheral(peripheral)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("didConnect to \(peripheral.name ?? "unnamed device")")
        self.peripheral = peripheral
        self.peripheral?.delegate = self 
        peripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        self.peripheral = nil 
    }
}

extension BluetoothViewModel: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        characteristics = service.characteristics
        
        for characteristic in characteristics ?? [] {
            peripheral.readValue(for: characteristic)
            peripheral.setNotifyValue(true, for: characteristic)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services, error == nil else {
            // handle error
            return
        }
        
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let data = characteristic.value else { return }
        isDataReady = true
        switch characteristic.uuid.uuidString.lowercased() {
        case SEWAGE_TEMPERATURE_ID:
            sewageTemperature = parseFloat(data: data)
        case WATER_FLOW_ID:
            print("WATER_FLOW_ID")
            
            guard let waterFlowData: WaterFlowData = parseStruct(data: data) else { return }
            self.waterFlowData = waterFlowData
            print(waterFlowData)
        case ADC_ID:
            print("ADC_ID")
            
            guard let adcData: AdcData = parseStruct(data: data) else { return }
            self.adcData = adcData
            print(adcData)
        case INVERTER_ID:
            isInverterOn = parseBool(data: data)
        case WATERPUMP_ID:
            waterpumpIsOn = parseBool(data: data)
        case TANK_HEATER_ID:
            tankHeaterIsOn = parseBool(data: data)
        case SEWAGE_VALVE_ID:
            isSewageValveOpen = parseBool(data: data)
        case IS_LOCKED_ID:
            print("isLocked \(parseBool(data: data))")
            isLocked = parseBool(data: data)
        case ACCELERATION_ID:
            print("ACCELERATION_ID")
            guard let accData: AccelerationData = parseStruct(data: data) else { return }
            self.accData = accData
            print(accData)
        case VE_DIRECT_ID:
            print("VE_DIRECT_ID")
            print(data)
            guard let veDirectData: VEDirectData = parseStruct(data: data) else { return }
            self.veDirectData = veDirectData
            print(accData)
        case ADC_SETTINGS_ID:
            print("ADC_SETTINGS_ID")
            print(data)
            guard let adcSettings: ADCSettings = parseStruct(data: data) else { return }
            self.adcSettings = adcSettings
            print(adcSettings)
        case SERVO_SETTINGS_ID:
            print("SERVO_SETTINGS_ID")
            print(data)
            guard let servoSettings: ServoSettings = parseStruct(data: data) else { return }
            self.servoSettings = servoSettings
            print(servoSettings)
        case FLOW_SETTINGS_ID:
            print("FLOW_SETTINGS_ID")
            print(data)
            guard let flowSettings: FlowSettings = parseStruct(data: data) else { return }
            self.flowSettings = flowSettings
            print(flowSettings)
        default:
            break
        }
    }
    
    func parseStruct<T>(data: Data) -> T? {
        print(data.count)
        print(MemoryLayout<T>.size)
//        guard data.count >= MemoryLayout<T>.size else {
//            print("Received data size is smaller than the expected struct size.")
//            return nil
//        }
        
        let decodedData = data.withUnsafeBytes { bufferPointer in
            bufferPointer.baseAddress.map { $0.assumingMemoryBound(to: T.self).pointee }
        }
        
        guard let validDecodedData = decodedData else {
            print("Failed to parse data of type \(T.Type.self).")
            return nil
        }
        
        return validDecodedData
    }
    
    func parseFloat(data: Data) -> Float {
        let bytes:Array<UInt8> = data.map { $0 }

        var value:Float = 0.0

        memcpy(&value, bytes, 4)
        return value
    }
    
    func parseBool(data: Data) -> Bool {
        return data.first == 1
    }
}


struct ContentView: View {
    @StateObject private var bluetoothViewModel = BluetoothViewModel()
    @Environment(\.scenePhase) var scenePhase
    
    var body: some View {
        NavigationView {
            HStack {
                if bluetoothViewModel.peripheral != nil {
                    DetailView()
                    
                } else {
                    ListView()
                }
            }
        }
        .environmentObject(bluetoothViewModel)
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                print("Active")
                bluetoothViewModel.scanForDevices()
            } else if newPhase == .inactive {
                print("Inactive")
            } else if newPhase == .background {
                print("Background")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension String {
    
    func hexStringtoAscii() -> String {

        let pattern = "(0x)?([0-9a-f]{2})"
        let regex = try! NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let nsString = self as NSString
        let matches = regex.matches(in: self, options: [], range: NSMakeRange(0, nsString.length))
        let characters = matches.map {
            Character(UnicodeScalar(UInt32(nsString.substring(with: $0.range(at: 2)), radix: 16)!)!)
        }
        return String(characters)
    }
}

