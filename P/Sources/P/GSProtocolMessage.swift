//
//  GSProtocolMessage.swift
//  P
//
//  Created by Nguyen Dung on 5/3/17.
//
//

import Foundation
//
//  GSMessage.swift
//  P
//
//  Created by Nguyen Dung on 4/18/17.
//
//
/*
 |Start Header|                    Header                 |      ID     |payload size|   PAYLOAD   |
 |   2 byte   |                    1 Byte                 | 1 -> 2 byte | 1 -> 4 byte|             |
 | 0xEE  0xEE |Ma Hoa | Type  |size ID | playload |is Zip |             |            |     ZIP     |
 |            | 1 bit | 2 bit | 2 bit  | 2 bit    | 1 bit |             |            |             |
 */

import Foundation
import Gzip
public enum GSProtocolMessageError: Error {
    case invalidData
    case invalidInput
    case invalidBufferSize
}


public class GSProtocolMessage{
    private var idByteSize              : UInt8 = 0 // value 1 - > 2 byte
    private var payloadByteSize         : UInt8 = 0 // value 1 - > 4 byte // ~ 4GB subport
    private var isZipPayload            : Bool = false
    private var isEncrypt               : Bool = true
    #if os(Linux)
    private var encryptType             : UInt8 = UInt8(random() % 2)
    #else
    private var encryptType             : UInt8 = UInt8(arc4random_uniform(2))
    #endif
    var totalMessageSize                : Int32 = 0
    var protoContent                    : Data?
    var headCodeId                      : UInt8 = 0
    var subCodeId                       : UInt8 = 0
    var isNext                          : Bool = false
    public init() {
        
    }
    
    public convenience init(rawData : Data) throws{
        self.init()
        guard rawData.count >= 3 else {
            throw GSProtocolMessageError.invalidData
        }
        guard rawData[0] == 0xEE && rawData[1] == 0xEE else {
            throw GSProtocolMessageError.invalidData
        }
        let header = rawData[2]
        
        isEncrypt           = (header.b7 == 0) ? false : true
        isZipPayload        = (header.b0 == 0) ? false : true
        encryptType         = ((header << 1) >> 6)
        idByteSize          = ((header << 3) >> 6) + 1
        payloadByteSize     = ((header << 5) >> 6) + 1
        
        guard rawData.count >= Int(3 + idByteSize + payloadByteSize) else {
            throw GSProtocolMessageError.invalidData
        }
        
        let msgIdData = rawData.subdata(in: 3 ..< Int(3 + idByteSize))
        if(idByteSize == 1){
            self.headCodeId = msgIdData[0].toU8 >> 4
            self.subCodeId = (msgIdData[0].toU8 << 4) >> 4
            
        }else{
            self.headCodeId = msgIdData[0].toU8
            self.subCodeId = msgIdData[1].toU8
        }
        
        guard let payloadSize = rawData.subdata(in: Int(3 + idByteSize) ..< Int(3 + idByteSize + payloadByteSize)).getInt32 else {
            throw GSProtocolMessageError.invalidData
        }
        totalMessageSize = payloadSize
        
        
        guard rawData.count >= Int(totalMessageSize)  else{
            throw GSProtocolMessageError.invalidBufferSize
        }
        
        if(rawData.count > Int(totalMessageSize)){
            isNext = true
        }
        
        var content = rawData.subdata(in: Int(3 + idByteSize + payloadByteSize) ..< rawData.count)
        
        if(isEncrypt){
            content = content.decrypt(code: Int(encryptType))
        }
        if(isZipPayload){
            do{
                content = try content.gunzipped()
            }catch{
                throw error
            }
        }
        protoContent = content
        
    }
    
    public func data() throws -> Data{
        guard headCodeId != 0 && subCodeId != 0 else {
            throw GSProtocolMessageError.invalidInput
        }
        
        
        var header : UInt8 = 0
        header = header.setb7(isEncrypt ? 1 : 0)
        if(encryptType == 1){
            header = header.setb6(0)
            header = header.setb5(1)
            
        }else if(encryptType == 2){
            header = header.setb6(1)
            header = header.setb5(0)
            
        }else if(encryptType == 3){
            header = header.setb6(1)
            header = header.setb5(1)
            
        }
        if(protoContent !=  nil && protoContent!.count > 35){
            isZipPayload = true
        }
        header = header.setb0(isZipPayload ? 1 : 0)
        if(headCodeId <= 15 && subCodeId <= 15){
            idByteSize = 0
        }else{
            idByteSize = 1
            header = header.setb4(0)
            header = header.setb3(1)
        }
        
        var content : Data? = Data()
        
        if(protoContent == nil){
            totalMessageSize = 5
        }else{
            content = self.protoContent
            if(isZipPayload){
                do{
                    content = try self.protoContent?.gzipped(level: .bestSpeed)
                }
                catch{
                    throw error
                }
            }
            
            if(isEncrypt){
                content =  content?.encrypt(code: Int(encryptType))
            }
            guard content != nil else {
                throw GSProtocolMessageError.invalidInput
            }
            
            totalMessageSize = 3 + Int32(idByteSize + 1) + Int32(content?.count ?? 0)
            if(totalMessageSize <= 0xFE){
                payloadByteSize = 0
            }else if(totalMessageSize > 0xFE && totalMessageSize <= 0xFFFD){
                payloadByteSize = 1
                header = header.setb2(0)
                header = header.setb1(1)
            }else if(totalMessageSize > 0xFFFD && totalMessageSize <= 0xFFFFFC){
                payloadByteSize = 2
                header = header.setb2(1)
                header = header.setb1(0)
            }else{
                payloadByteSize = 3
                header = header.setb2(1)
                header = header.setb1(1)
            }
            totalMessageSize += Int32(payloadByteSize + 1)
        }
        
        
        var rawData = Data()
        
        rawData.append([0xEE,0xEE], count: 2)
        rawData.append([header], count: 1)
        
        
        if(idByteSize == 0){
            var x : UInt8 = 0
            x = x.setb7(Int(self.headCodeId.b3))
            x = x.setb6(Int(self.headCodeId.b2))
            x = x.setb5(Int(self.headCodeId.b1))
            x = x.setb4(Int(self.headCodeId.b0))
            x = x.setb3(Int(self.subCodeId.b3))
            x = x.setb2(Int(self.subCodeId.b2))
            x = x.setb1(Int(self.subCodeId.b1))
            x = x.setb0(Int(self.subCodeId.b0))
            
            rawData.append([x], count: 1)
        }else if(idByteSize == 1){
            rawData.append([self.headCodeId,self.subCodeId], count: 2)
        }
        
        if(payloadByteSize == 0){
            rawData.append([UInt8(totalMessageSize)], count: 1)
        }else if(payloadByteSize == 1){
            rawData.append([UInt8((totalMessageSize >> 8) & 0xFF),UInt8(totalMessageSize & 0xFF)], count: 2)
        }else if(payloadByteSize == 2){
            rawData.append([UInt8((totalMessageSize >> 16) & 0xFF),UInt8((totalMessageSize >> 8) & 0xFF),UInt8(totalMessageSize & 0xFF)], count: 3)
        }else{
            rawData.append([UInt8((totalMessageSize >> 24) & 0xFF),UInt8((totalMessageSize >> 16) & 0xFF),UInt8((totalMessageSize >> 8) & 0xFF),UInt8(totalMessageSize & 0xFF)], count: 4)
        }
        if(content != nil){
            rawData.append(content!)
        }
        return rawData
        
        
        
        
        
    }
}
