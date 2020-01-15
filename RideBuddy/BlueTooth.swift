import Foundation
import CoreBluetooth
import Combine
import SwiftUI

private let heartRateMeasurementCharacteristicCBUUID = CBUUID(string: "0x2A37")
private let batteryLevelCharacteristicCBUUID = CBUUID(string: "0x2A19")

class BlueToothAccess: NSObject {
    var centralManager: CBCentralManager?
    var heartRatePeripheral: CBPeripheral!

    let heartRatePublisher = PassthroughSubject<Int, Never>()
    let batteryLevelPublisher = PassthroughSubject<Double, Never>()

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
}

extension BlueToothAccess: CBCentralManagerDelegate {
  func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("central mangler did update state \(central.state)")

        switch central.state {
        case .unknown:
            print("unknown")
        case .resetting:
            print("resetting")
        case .unsupported:
            print("unsupported")
        case .unauthorized:
            print("unauthorized")
        case .poweredOff:
            print("poweredOff")
        case .poweredOn:
            print("poweredOn")
            let heartRateServiceCBUUID = CBUUID(string: "0x180D")
            centralManager?.scanForPeripherals(withServices: [heartRateServiceCBUUID])
        @unknown default:
            print("new improved unknown case! \(central.state)")
        }
    }

    func centralManager(_ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any],
        rssi RSSI: NSNumber) {
        print("did discover \(peripheral)")
        heartRatePeripheral = peripheral
        centralManager?.stopScan()

        print("    connecting...")
        centralManager?.connect(heartRatePeripheral)
    }

    func centralManager(_ central: CBCentralManager,
        didConnect peripheral: CBPeripheral) {
        print("did connect!")
        heartRatePeripheral.delegate = self

        let heartRateServiceCBUUID = CBUUID(string: "0x180D")
        let batteryServiceCBUUID = CBUUID(string: "0x180F")
        // battery level 0x2A19
        let allTheThings = [heartRateServiceCBUUID, batteryServiceCBUUID]

        heartRatePeripheral.discoverServices(allTheThings)
//        heartRatePeripheral.discoverServices(nil)
    }
}

extension BlueToothAccess: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else {
            return print("did not find services?")
        }

        services.forEach {
            print($0, $0.uuid)
            print("   .. discovering characteristics")
            peripheral.discoverCharacteristics(nil, for: $0)
        }
    }

    func peripheral(_ peripheral: CBPeripheral,
        didDiscoverCharacteristicsFor service: CBService,
        error: Error?) {
        guard let characteristics = service.characteristics else {
            return print("did not find characteristics")
        }

        for characteristic in characteristics {
            print(characteristic)
            if characteristic.properties.contains(.read) {
                print("    has .read")
                peripheral.readValue(for: characteristic)
            }
            if characteristic.properties.contains(.notify) {
                print("    has .notify")
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, 
        didUpdateValueFor characteristic: CBCharacteristic,
                error: Error?) {
        switch characteristic.uuid {
        case batteryLevelCharacteristicCBUUID:
            print("battery has value", characteristic.value?.hexDescription ?? "no value")
            if let charge = batteryLevel(from: characteristic) {
                print("charge \(charge)")
                batteryLevelPublisher.send(charge)
            }
        case heartRateMeasurementCharacteristicCBUUID:
            guard let bpm = heartRate(from: characteristic) else {
                break
            }
            print("lub-dub \(bpm)")
            heartRatePublisher.send(bpm)
        default:
            print("unhandled uuid \(characteristic.uuid) has value \(characteristic.value?.hexDescription ?? "---")")

        }
    }

    private func bodyLocation(from characteristic: CBCharacteristic) -> String {
        guard let characteristicData = characteristic.value,
        let byte = characteristicData.first else { return "Error" }
        
        switch byte {
        case 0: return "Other"
        case 1: return "Snarnge"
        case 2: return "Wrist"
        case 3: return "Finger"
        case 4: return "Hand"
        case 5: return "Ear Lobe"
        case 6: return "Foot"
        default:
            return "Reserved for future use"
        }
    }

    private func heartRate(from characteristic: CBCharacteristic) -> Int? {
        guard let characteristicData = characteristic.value else {
            print("could not get heart rate characteristic data")
            return nil
        }
        let byteArray = [UInt8](characteristicData)
        guard byteArray.count >= 1 else {
            print("unexpectedly small byte array count")
            return nil
        }

        let firstBitValue = byteArray[0] & 0x01
        if firstBitValue == 0 {
            guard byteArray.count >= 2 else {
                print("unexpectedly small byte array count for one-byte heart rate")
                return nil
            }

            // heart rate is in the second byte
            return Int(byteArray[1])
        } else {
            guard byteArray.count >= 3 else {
                print("unexpectedly small byte array count for two-byte heart rate")
                return nil
            }
            return (Int(byteArray[1]) << 8) + Int(byteArray[2])
        }
    }

    private func batteryLevel(from characteristic: CBCharacteristic) -> Double? {
        guard let characteristicData = characteristic.value else {
            print("could not get battery characteristic data")
            return nil
        }

        let byteArray = [UInt8](characteristicData)
        guard byteArray.count >= 1 else {
            print("unexpectedly small byte array count")
            return nil
        }

        let percent = Double(byteArray[0]) / 100.0
        return percent
        
    }
}

struct BlueToothAccessKey: EnvironmentKey {
    static let defaultValue: BlueToothAccess = BlueToothAccess()
}

extension EnvironmentValues {
    var bluetoothAccess: BlueToothAccess {
        get {
            return self[BlueToothAccessKey.self]
        }
        set {
            self[BlueToothAccessKey.self] = newValue
        }
    }
}
