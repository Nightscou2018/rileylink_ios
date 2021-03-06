//
//  ConfirmPairingCommand.swift
//  OmniKit
//
//  Created by Pete Schwamb on 2/17/18.
//  Copyright © 2018 Pete Schwamb. All rights reserved.
//

import Foundation

public struct ConfirmPairingCommand : MessageBlock {
    
    public let blockType: MessageBlockType = .confirmPairing
    
    let address: UInt32
    let lot: UInt32
    let tid: UInt32
    let dateComponents: DateComponents
    
    public static func dateComponents(date: Date, timeZone: TimeZone) -> DateComponents {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = timeZone
        return cal.dateComponents([.day, .month, .year, .hour, .minute], from: date)
    }
    
    public static func date(from components: DateComponents, timeZone: TimeZone) -> Date? {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = timeZone
        return cal.date(from: components)
    }
    
    // 03 13 1f08ced2 14 04 09 0b 11 0b 08 0000a640 00097c27 83e4
    public var data: Data {
        var data = Data(bytes: [
            blockType.rawValue,
            19,
            ])
        data.appendBigEndian(self.address)
        
        let year = UInt8((dateComponents.year ?? 2000) - 2000)
        let month = UInt8(dateComponents.month ?? 0)
        let day = UInt8(dateComponents.day ?? 0)
        let hour = UInt8(dateComponents.hour ?? 0)
        let minute = UInt8(dateComponents.minute ?? 0)
        
        let data2: Data = Data(bytes: [
            UInt8(0x14), // Unknown
            UInt8(0x04), // Unknown
            day,
            month,
            year,
            hour,
            minute
            ])
        data.append(data2)
        data.appendBigEndian(self.lot)
        data.appendBigEndian(self.tid)
        return data
    }
    
    public init(encodedData: Data) throws {
        if encodedData.count < 21 {
            throw MessageBlockError.notEnoughData
        }
        self.address = encodedData[2...].toBigEndian(UInt32.self)
        var components = DateComponents()
        components.day = Int(encodedData[8])
        components.month = Int(encodedData[9])
        components.year = Int(encodedData[10]) + 2000
        components.hour = Int(encodedData[11])
        components.minute = Int(encodedData[12])
        self.dateComponents = components
        self.lot = encodedData[13...].toBigEndian(UInt32.self)
        self.tid = encodedData[17...].toBigEndian(UInt32.self)
    }
    
    public init(address: UInt32, dateComponents: DateComponents, lot: UInt32, tid: UInt32) {
        self.address = address
        self.dateComponents = dateComponents
        self.lot = lot
        self.tid = tid
    }
}
