//
//  GSProtocolMessageType.swift
//  P
//
//  Created by Nguyen Dung on 4/28/17.
//
//

import Foundation
struct GSProtocolMessageType {
    struct headCode {
        static let profile : UInt8 =  0x1
    }
    struct subCode {
        static let profile_KeepAlive : UInt8 = 0x1
        static let profile_login : UInt8 = 0x2
    }
}
