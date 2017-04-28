//
//  ConfigManager.swift
//  P
//
//  Created by Nguyen Dung on 4/27/17.
//
//

import Foundation

public enum SettingError : Error{
    case tcpFileSettingNotFound
    case parseFileSettingError
}


public class ConfigManager{
    
    public static let sharedInstance = ConfigManager()

    public init() { }
    
    
    public var getHost : String{
        return "127.0.0.1"
    }
    public var getBindHost : String{
        return "0.0.0.0"
    }
    public var getTcpPort : Int {
        return 4444
    }
    public var getUdpPort : Int {
        return 4445
    }    
    public var dbHost : String{
        return "localhost"
    }
    public var dbPort : Int {
        return 6379
    }
    public var dbPassword : String{
        return "password123"
    }
    
}
