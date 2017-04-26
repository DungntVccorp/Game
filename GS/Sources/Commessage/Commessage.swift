//
//  SessionManager.swift
//  GS
//
//  Created by Nguyen Dung on 11/29/16.
//
//
/**
 Cấu trúc header của message
 0xA9 0xA9 0xA9 (3)|Size (3)|Type (2)|Message Id (8)|Data (Protobuf message)
 */

import Foundation
import LoggerAPI

public extension Data{
    
    //MARK: - 🆑 Custom Method
    
    init<T>(from value: T) {
        var value = value
        self.init(buffer: UnsafeBufferPointer(start: &value, count: 1))
    }
    
    
    func to<T>(type: T.Type) -> T {
        return self.withUnsafeBytes { $0.pointee }
    }
    
    var binary : [UInt8] {
        return self.withUnsafeBytes {
            Array(UnsafeBufferPointer<UInt8>(start: $0, count: self.count/MemoryLayout<UInt8>.size))
        }
    }
    
    var getInt32 : Int32? {
        guard self.count <= MemoryLayout<Int32>.size else {
            return nil
        }
        var binary = self.binary
        if(binary.count < MemoryLayout<Int32>.size){
            let numberInsert = MemoryLayout<Int32>.size - binary.count
            for _ in 0..<numberInsert{
                binary.insert(0, at: 0)
            }
        }
        let bigEndianValue = binary.withUnsafeBufferPointer {
            ($0.baseAddress!.withMemoryRebound(to: Int32.self, capacity: 1) { $0 })
            }.pointee
        return Int32(bigEndian: bigEndianValue)
    }
    var getUInt32 : UInt32? {
        guard self.count <= MemoryLayout<UInt32>.size else {
            return nil
        }
        var binary = self.binary
        if(binary.count < MemoryLayout<UInt32>.size){
            let numberInsert = MemoryLayout<UInt32>.size - binary.count
            for _ in 0..<numberInsert{
                binary.insert(0, at: 0)
            }
        }
        let bigEndianValue = binary.withUnsafeBufferPointer {
            ($0.baseAddress!.withMemoryRebound(to: UInt32.self, capacity: 1) { $0 })
            }.pointee
        return UInt32(bigEndian: bigEndianValue)
    }
    var getInt64 : Int64? {
        guard self.count <= MemoryLayout<Int64>.size else {
            return nil
        }
        var binary = self.binary
        if(binary.count < MemoryLayout<Int64>.size){
            let numberInsert = MemoryLayout<Int64>.size - binary.count
            for _ in 0..<numberInsert{
                binary.insert(0, at: 0)
            }
        }
        let bigEndianValue = binary.withUnsafeBufferPointer {
            ($0.baseAddress!.withMemoryRebound(to: Int64.self, capacity: 1) { $0 })
            }.pointee
        return Int64(bigEndian: bigEndianValue)
    }
    var getUInt64 : UInt64? {
        guard self.count <= MemoryLayout<UInt64>.size else {
            return nil
        }
        var binary = self.binary
        if(binary.count < MemoryLayout<UInt64>.size){
            let numberInsert = MemoryLayout<UInt64>.size - binary.count
            for _ in 0..<numberInsert{
                binary.insert(0, at: 0)
            }
        }
        let bigEndianValue = binary.withUnsafeBufferPointer {
            ($0.baseAddress!.withMemoryRebound(to: UInt64.self, capacity: 1) { $0 })
            }.pointee
        return UInt64(bigEndian: bigEndianValue)
    }
    var getInt : Int? {
        guard self.count <= MemoryLayout<Int>.size else {
            return nil
        }
        var binary = self.binary
        if(binary.count < MemoryLayout<Int>.size){
            let numberInsert = MemoryLayout<Int>.size - binary.count
            for _ in 0..<numberInsert{
                binary.insert(0, at: 0)
            }
        }
        let bigEndianValue = binary.withUnsafeBufferPointer {
            ($0.baseAddress!.withMemoryRebound(to: Int.self, capacity: 1) { $0 })
            }.pointee
        return Int(bigEndian: bigEndianValue)
    }
}


public enum CommessageError : Error{
    case data_invalid
    case header_invalid
    case size_invalid
}

public struct Commessage{
    public private(set) var msg_size : Int? = 16
    public private(set) var msg_type : Int32?
    public private(set) var msg_rID  : UInt64?
    public private(set) var msg_data : Data?
    public init(_ msgType: Int32,_ msgId: UInt64,_ msgData: Data) {
        self.msg_type = msgType
        self.msg_rID = msgId
        self.msg_data = msgData
        self.msg_size = msgData.count + 16
    }
    public init(rawData: Data) throws{
        Log.verbose("read message")

        guard rawData.count > 16 else {
            throw CommessageError.data_invalid
        }
        guard rawData[0] == 0xA9 && rawData[1] == 0xA9 && rawData[2] == 0xA9 else{
            throw CommessageError.header_invalid
        }
        guard let size = rawData.subdata(in: 0x3..<0x6).getInt else {
            throw CommessageError.data_invalid
        }
        guard size == rawData.count else{
            throw CommessageError.size_invalid
        }
        self.msg_size = size
        guard let type = rawData.subdata(in: 0x6..<0x8).getInt32 else{
            throw CommessageError.data_invalid
        }
        self.msg_type = type
        guard let Id = rawData.subdata(in: 0x8..<0x10).getUInt64 else {
            throw CommessageError.data_invalid
        }
        self.msg_rID = Id
        self.msg_data = rawData.subdata(in: 0x10..<rawData.count)
    }
    
    public func data() throws -> Data{
        guard msg_size == 16 else{
            throw CommessageError.data_invalid
        }
        var rawData = Data()
        rawData.append([0xA9,0xA9,0xA9], count: 3) // header
        rawData.append([UInt8((self.msg_size! >> 16) & 0xFF),
                        UInt8((self.msg_size! >> 8) & 0xFF),
                        UInt8(self.msg_size! & 0xFF)], count: 3) // message size
        rawData.append([UInt8((self.msg_type! >> 8) & 0xFF),
                        UInt8(self.msg_type! & 0xFF)], count: 2) // message type
        rawData.append([UInt8((self.msg_rID! >> 56) & 0xFF),
                        UInt8((self.msg_rID! >> 48) & 0xFF),
                        UInt8((self.msg_rID! >> 40) & 0xFF),
                        UInt8((self.msg_rID! >> 32) & 0xFF),
                        UInt8((self.msg_rID! >> 24) & 0xFF),
                        UInt8((self.msg_rID! >> 16) & 0xFF),
                        UInt8((self.msg_rID! >> 8) & 0xFF),
                        UInt8(self.msg_rID! & 0xFF)], count: 8) // message ID
        rawData.append(self.msg_data!) // proto data
        return rawData
    }
    
    
    
}
