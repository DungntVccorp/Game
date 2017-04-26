//
//  GSMessage.swift
//  P
//
//  Created by Nguyen Dung on 4/18/17.
//
//
/*
    |Start Header|                    Header                 |      ID     |payload size|   PAYLOAD   |
    |   2 byte   |                    1 Byte                 | 1 -> 4 byte | 1 -> 4 byte|             |
    | 0xEE  0xEE |Ma Hoa | Type  |size ID | playload |is Zip |             |            |     ZIP     |
    |            | 1 bit | 2 bit | 2 bit  | 2 bit    | 1 bit |             |            |             |
 */

import Foundation
import Gzip
public enum GSMessageError: Error {
    case invalidData
    case invalidInput
}


public class GSMessage{
    
    var isEncrypt                       : Bool = false
    var encryptType                     : UInt8 = 0
    var isZipPayload                    : Bool = false
    private var idByteSize              : UInt8 = 0 // value 1 - > 4 byte
    private var payloadByteSize         : UInt8 = 0 // value 1 - > 4 byte // ~ 4GB subport
    var messageId                       : Int32 = 0
    var totalMessageSize                : Int32 = 0
    var protoContent                    : Data?
    
    public init() {
        
    }
    
    public convenience init(rawData : Data) throws{
        self.init()
        guard rawData.count >= 3 else {
            throw GSMessageError.invalidData
        }
        guard rawData[0] == 0xEE && rawData[1] == 0xEE else {
            throw GSMessageError.invalidData
        }
        let header = rawData[2]
        
        isEncrypt           = (header.b7 == 0) ? false : true
        isZipPayload        = (header.b0 == 0) ? false : true
        encryptType         = ((header << 1) >> 6)
        idByteSize          = ((header << 3) >> 6) + 1
        payloadByteSize     = ((header << 5) >> 6) + 1
        
        guard rawData.count >= Int(3 + idByteSize + payloadByteSize) else {
            throw GSMessageError.invalidData
        }
        guard let idGSMsg = rawData.subdata(in: 3 ..< Int(3 + idByteSize)).getInt32 else {
            throw GSMessageError.invalidData
        }
        messageId = idGSMsg
        
        guard let payloadSize = rawData.subdata(in: Int(3 + idByteSize) ..< Int(3 + idByteSize + payloadByteSize)).getInt32 else {
            throw GSMessageError.invalidData
        }
        totalMessageSize = payloadSize
        
        
        guard rawData.count >= Int(totalMessageSize)  else{
            throw GSMessageError.invalidData
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
        guard messageId != 0 else {
            throw GSMessageError.invalidInput
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
        
        header = header.setb0(isZipPayload ? 1 : 0)
        
        if(messageId > 0 && messageId <= 0xFF){
            idByteSize = 0
        }else if(messageId > 0xFF && messageId <= 0xFFFF){
            idByteSize = 1
            header = header.setb4(0)
            header = header.setb3(1)
        }else if(messageId > 0xFFFF && messageId <= 0xFFFFFF){
            idByteSize = 2
            header = header.setb4(1)
            header = header.setb3(0)
        }else{
            idByteSize = 3
            header = header.setb4(1)
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
                throw GSMessageError.invalidInput
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
            rawData.append([UInt8(messageId)], count: 1)
        }else if(idByteSize == 1){
            rawData.append([UInt8((messageId >> 8) & 0xFF),UInt8(messageId & 0xFF)], count: 2)
        }else if(idByteSize == 2){
            rawData.append([UInt8((messageId >> 16) & 0xFF),UInt8((messageId >> 8) & 0xFF),UInt8(messageId & 0xFF)], count: 3)
        }else{
            rawData.append([UInt8((messageId >> 24) & 0xFF),UInt8((messageId >> 16) & 0xFF),UInt8((messageId >> 8) & 0xFF),UInt8(messageId & 0xFF)], count: 4)
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
