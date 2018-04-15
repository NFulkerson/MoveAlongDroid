//
//  ViewController.swift
//  MoveAlongDroid
//
//  Created by Nathan on 4/12/18.
//  Copyright © 2018 Nathan Fulkerson. All rights reserved.
//

import UIKit
import CoreBluetooth

class DroidViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    var manager: CBCentralManager?
    var peripherals: CBPeripheral?
    var data: Data?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        if manager != nil {
            return
        } else {
            manager = CBCentralManager(delegate: self, queue: nil)
        }

        let button = UIButton(type: .roundedRect)
        button.backgroundColor = .blue
        button.setTitle("Diagnostics", for: .normal)

        view.addSubview(button)
        button.addTarget(self, action: #selector(printDiagnostic), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            button.widthAnchor.constraint(equalToConstant: 200),
            button.heightAnchor.constraint(equalToConstant: 50)
            ])

    }

    @objc func printDiagnostic() {
        wakeDroid()
    }

    func wakeDroid() {
        guard let peripheral = peripherals, let services = peripheral.services,
            let radioService: CBService = services.first(where: {$0.uuid == Droid.Services.radio.uuid()}),
        let characteristics = radioService.characteristics else {
            print("Peripheral or radio service are nil")
            return
        }
        let antidos = characteristics.first(where: {$0.uuid == Droid.RadioCharacteristic.antiDOS.uuid()})
        let tx = characteristics.first(where: {$0.uuid == Droid.RadioCharacteristic.txPower.uuid()})
        let wake = characteristics.first(where: {$0.uuid == Droid.RadioCharacteristic.wakeup.uuid()})


        let unlock: Data = "011i3".data(using: .utf8)!
        peripheral.writeValue(unlock, for: antidos!, type: .withResponse)
        let powerByte: Data = Data(bytes: [0,7])
        peripheral.writeValue(powerByte, for: tx!, type: .withResponse)
        let wakeBytes: Data = Data(bytes: [1])
        peripheral.writeValue(wakeBytes, for: wake!, type: .withResponse)

    }

    func changeDroidColor() {
        print(command())
    }

    func command(did: UInt8 = 0x02, cid: UInt8 = 0x20, dlen: UInt8 = 0x05, answer: Bool = true, reset: Bool = true) -> Data {
        var zero: UInt8 = 0
        var payload = Data(bytes: &zero, count: 6)
        payload[0] = 0xFF
        payload[1] = 0b11111111
        payload[2] = did
        payload[3] = cid
        payload[4] = 0

        let colorData = Data(bytes: [0,0,255,0])
        payload[5] = UInt8(colorData.count + 1)
        payload.append(colorData)

        let checksumTarget = payload[2 ..< payload.count]

        var checksum: UInt8 = 0
        for byte in checksumTarget {
            checksum = checksum &+ byte
        }
        checksum = ~checksum
        payload.append(Data(bytes: [checksum]))
        return payload
    }

    // MARK: - Central Manager

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected!")
        manager?.stopScan()
        data?.removeAll(keepingCapacity: true)
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if RSSI.intValue > -15 {
            //            print("peripheral too far: \(peripheral)")
            return
        }
        if RSSI.intValue < -75 {
            //            print("Too low. \(peripheral)")
            return
        }

        if self.peripherals == peripheral {
            return
        } else {
            peripherals = peripheral
            print("Found peripheral \(peripheral.name) at \(RSSI)")
            print("Added \(peripheral.name)")
            print(peripherals)
            manager?.connect(peripheral, options: nil)

        }
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Connection failed to \(peripheral)")
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == CBManagerState.poweredOn {
            startScan()

        } else {
            print("Device not powered on.")
        }
    }

    func startScan() {
        let services = [Droid.Services.radio.uuid(), Droid.Services.robot.uuid()]
        manager?.scanForPeripherals(withServices: services, options: nil)
        print("Scanning!...")
    }

    // MARK: - Peripheral Delegate methods

    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        print(characteristic.descriptors)
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("Peripheral service: \(service) has characteristics: \(service.characteristics)")
        guard let characteristics = service.characteristics else {
            return
        }
        for characteristic in characteristics {
            peripheral.discoverDescriptors(for: characteristic)
        }

    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("Peripheral \(peripheral.name) has service: \(peripheral.services)")

        guard let services = peripheral.services else {
            return
        }

        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }

    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverIncludedServicesFor service: CBService, error: Error?) {
        print("Discovered included services for \(service)")
        print(service.includedServices)
    }

    func sendData() {
        guard let peripheral = peripherals else {
            print("no peripheral connected")
            return
        }

    }


}

