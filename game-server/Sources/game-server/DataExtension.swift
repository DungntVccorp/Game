//
//  DataExtension.swift
//  P
//
//  Created by Nguyen Dung on 4/17/17.
//
//

import Foundation
extension Data{
    //MARK: - 🆑 Custom Method
    
    public init<T>(from value: T) {
        var value = value
        self.init(buffer: UnsafeBufferPointer(start: &value, count: 1))
    }
    
    
    public func to<T>(type: T.Type) -> T {
        return self.withUnsafeBytes { $0.pointee }
    }
    
    public var binary : [UInt8] {
        return self.withUnsafeBytes {
            Array(UnsafeBufferPointer<UInt8>(start: $0, count: self.count/MemoryLayout<UInt8>.size))
        }
    }
    
    public var getInt32 : Int32? {
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
    public var getUInt32 : UInt32? {
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
    public var getInt64 : Int64? {
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
    public var getUInt64 : UInt64? {
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
    public var getInt : Int? {
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
    
    
    public func encrypt(code : Int) -> Data{
        if(self.count > 20){
            var newData = Data()
            for i in 0..<20{
                var b = self[i]
                
                if(code == 0){
                    if(b.b0 == 0){
                        b = b.setb0(1)
                    }else{
                        b = b.setb0(0)
                    }
                    if(b.b3 == 0){
                        b = b.setb3(1)
                    }else{
                        b = b.setb3(0)
                    }
                }else if(code == 1){
                    if(b.b1 == 0){
                        b = b.setb1(1)
                    }else{
                        b = b.setb1(0)
                    }
                    if(b.b4 == 0){
                        b = b.setb4(1)
                    }else{
                        b = b.setb4(0)
                    }
                }
                else if(code == 2){
                    if(b.b2 == 0){
                        b = b.setb2(1)
                    }else{
                        b = b.setb2(0)
                    }
                    if(b.b6 == 0){
                        b = b.setb6(1)
                    }else{
                        b = b.setb6(0)
                    }
                }
                else if(code == 3){
                    if(b.b3 == 0){
                        b = b.setb3(1)
                    }else{
                        b = b.setb3(0)
                    }
                    if(b.b7 == 0){
                        b = b.setb7(1)
                    }else{
                        b = b.setb7(0)
                    }
                }
                newData.append(b)
            }
            newData.append(self.subdata(in: 20..<self.count))

            return newData
        }
        return self
    }
    public func decrypt(code: Int) -> Data{
        if(self.count > 20){
            var newData = Data()
            for i in 0..<20{
                var b = self[i]
                
                if(code == 0){
                    if(b.b0 == 0){
                        b = b.setb0(1)
                    }else{
                        b = b.setb0(0)
                    }
                    if(b.b3 == 0){
                        b = b.setb3(1)
                    }else{
                        b = b.setb3(0)
                    }
                }else if(code == 1){
                    if(b.b1 == 0){
                        b = b.setb1(1)
                    }else{
                        b = b.setb1(0)
                    }
                    if(b.b4 == 0){
                        b = b.setb4(1)
                    }else{
                        b = b.setb4(0)
                    }
                }
                else if(code == 2){
                    if(b.b2 == 0){
                        b = b.setb2(1)
                    }else{
                        b = b.setb2(0)
                    }
                    if(b.b6 == 0){
                        b = b.setb6(1)
                    }else{
                        b = b.setb6(0)
                    }
                }
                else if(code == 3){
                    if(b.b3 == 0){
                        b = b.setb3(1)
                    }else{
                        b = b.setb3(0)
                    }
                    if(b.b7 == 0){
                        b = b.setb7(1)
                    }else{
                        b = b.setb7(0)
                    }
                }
                newData.append(b)
            }
            newData.append(self.subdata(in: 20..<self.count))
            
            return newData
        }
        return self
    }
    
    
}
