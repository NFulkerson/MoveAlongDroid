//
//  Droid.swift
//  MoveAlongDroid
//
//  Created by Nathan on 4/13/18.
//  Copyright © 2018 Nathan Fulkerson. All rights reserved.
//

import Foundation
import CoreBluetooth

struct Droid {
    // Service UUIDs were discovered via Bluecap app.
     enum Services: String {
        case radio = "22BB746F-2BB0-7554-2D6F-726568705327"
        case robot = "22BB746F-2BA0-7554-2D6F-726568705327"

        func uuid() -> CBUUID {
            return CBUUID(string: self.rawValue)
        }
    }

     enum RadioCharacteristic: String {
        case txPower = "22bb746f-2bb2-7554-2D6F-726568705327"
        case rssi = "22BB746F-2BB6-7554-2D6F-726568705327"
        case sleep = "22BB746F-2bb7-7554-2D6F-726568705327"
        case antiDOS = "22bb746f-2bbd-7554-2D6F-726568705327"
        case timeout = "22bb746f-2bbe-7554-2D6F-726568705327"
        case wakeup = "22bb746f-2bbf-7554-2D6F-726568705327"

        func uuid() -> CBUUID {
            let uuidString = self.rawValue
            return CBUUID(string: uuidString)
        }
    }

     enum RobotCharacteristic: String {
        case control = "22bb746F-2ba1-7554-2D6F-726568705327"
        case response
        case deviceInfo
        case model
        case serialNo
        case radioFirmware

        func uuid() -> CBUUID {
            let uuidString = self.rawValue
            return CBUUID(string: uuidString)
        }
    }

}
